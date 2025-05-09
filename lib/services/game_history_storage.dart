import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_history_entry.dart';
import '../models/game.dart';
import '../models/player.dart';
import 'package:uuid/uuid.dart';

class GameHistoryStorage {
  static const String _storageKey = 'game_history';

  // Sauvegarder une partie dans l'historique
  Future<void> saveGameToHistory(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final List<GameHistoryEntry> history = await loadGameHistory();

    // Trier les joueurs par score décroissant
    final List<Player> sortedPlayers = List.from(game.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    // Vérifier s'il y a égalité pour la première place
    bool isTie = false;
    String winnerName = 'Aucun gagnant';
    int winnerScore = 0;

    if (sortedPlayers.isNotEmpty) {
      winnerScore = sortedPlayers[0].score;

      // Compter combien de joueurs ont le score le plus élevé
      final tiedPlayers =
          sortedPlayers.where((player) => player.score == winnerScore).toList();

      if (tiedPlayers.length > 1) {
        // Cas d'égalité
        isTie = true;
        final names = tiedPlayers.map((p) => p.name).toList();
        winnerName = names.join(' et '); // Ex: "Alice et Bob"
      } else {
        // Cas normal (un seul gagnant)
        winnerName = sortedPlayers[0].name;
      }
    }

    // Créer une nouvelle entrée d'historique
    final historyEntry = GameHistoryEntry(
      id: const Uuid().v4(),
      dateTime: DateTime.now(),
      players: sortedPlayers,
      scoringItems: game.scoringItems,
      availableBetItems:
          game.availableBetItems, // Sauvegarde de tous les éléments disponibles
      winnerName: winnerName,
      winnerScore: winnerScore,
      isTie: isTie, // Indiquer s'il y a égalité
    );

    // Ajouter la nouvelle entrée à l'historique
    history.add(historyEntry);

    // Sauvegarder l'historique mis à jour
    final jsonHistory = history.map((entry) => entry.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonHistory));
  }

  // Charger l'historique des parties
  Future<List<GameHistoryEntry>> loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonHistory = jsonDecode(jsonString);
      return jsonHistory.map((json) => GameHistoryEntry.fromJson(json)).toList()
        // Trier par date décroissante (du plus récent au plus ancien)
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement de l\'historique: $e');
      }
      return [];
    }
  }

  // Supprimer une entrée de l'historique
  Future<void> deleteHistoryEntry(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<GameHistoryEntry> history = await loadGameHistory();

    // Filtrer l'entrée à supprimer
    final updatedHistory =
        history.where((entry) => entry.id != entryId).toList();

    // Sauvegarder l'historique mis à jour
    final jsonHistory = updatedHistory.map((entry) => entry.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonHistory));
  }

  // Effacer tout l'historique
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
