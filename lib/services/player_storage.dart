import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class PlayerStorage {
  static const String _storageKey = 'players';

  // Sauvegarder la liste des joueurs
  Future<void> savePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(players.map((player) => player.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // Charger la liste des joueurs
  Future<List<Player>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((playerJson) => Player.fromJson(playerJson)).toList();
    } catch (e) {
      // Utilisation de debugPrint en mode debug seulement
      debugPrint('Erreur lors du chargement des joueurs: $e');
      return [];
    }
  }
}