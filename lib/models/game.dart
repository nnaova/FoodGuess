import 'package:flutter/material.dart';
import 'bet_item.dart';
import 'player.dart';

enum GameState {
  setup, // Configuration de la partie
  playing, // Partie en cours
  scoring, // Sélection des éléments gagnants
  finished, // Partie terminée
}

class Game with ChangeNotifier {
  final List<BetItem> availableBetItems;
  final List<Player> players;
  int currentPlayerIndex = 0;
  GameState state = GameState.setup;
  List<BetItem> scoringItems = [];

  Game({
    required this.availableBetItems,
    required this.players,
    this.currentPlayerIndex = 0,
    this.state = GameState.setup,
  });

  // Joueur actuel
  Player get currentPlayer => players[currentPlayerIndex];

  // Éléments encore disponibles pour parier
  List<BetItem> get availableItems {
    // Récupérer tous les IDs d'éléments déjà pariés
    final betItemIds = players.expand((player) => player.betItemIds).toList();

    // Retourner les éléments qui n'ont pas encore été pariés
    return availableBetItems
        .where((item) => !betItemIds.contains(item.id))
        .toList();
  }

  // Passer au joueur suivant
  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    notifyListeners();
  }

  // Ajouter un pari pour le joueur actuel
  void placeBet(String betItemId) {
    if (state == GameState.playing) {
      currentPlayer.addBet(betItemId);

      // Si tous les éléments ont été pariés ou si plus d'éléments disponibles
      if (availableItems.isEmpty) {
        state = GameState.scoring;
      } else {
        nextPlayer();
      }

      notifyListeners();
    }
  }

  // Démarrer la partie
  void startGame() {
    state = GameState.playing;
    notifyListeners();
  }

  // Terminer la partie manuellement
  void endGame() {
    state = GameState.scoring;
    notifyListeners();
  }

  // Définir les éléments qui rapportent des points
  void setScoringItems(List<BetItem> items) {
    scoringItems = items;

    // Marquer les éléments comme rapportant des points
    for (final item in availableBetItems) {
      final isScoring = items.any((scoringItem) => scoringItem.id == item.id);
      item.isScoring = isScoring;
    }

    // Calculer les scores de tous les joueurs
    for (final player in players) {
      player.calculateScore(scoringItems);
    }

    state = GameState.finished;
    notifyListeners();
  }

  // Réinitialiser pour une nouvelle partie avec les mêmes joueurs
  void resetGame() {
    // Réinitialiser les paris et scores des joueurs
    for (final player in players) {
      player.betItemIds = [];
      player.score = 0;
    }

    // Réinitialiser l'état du jeu
    currentPlayerIndex = 0;
    state = GameState.playing;
    scoringItems = [];

    notifyListeners();
  }
}
