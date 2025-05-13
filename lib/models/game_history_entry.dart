import 'bet_item.dart';
import 'player.dart';
import 'game.dart';

enum GameHistoryStatus {
  inProgress, // Partie en cours (paris en cours)
  waitingResults, // En attente des résultats (paris terminés)
  completed, // Partie terminée
}

class GameHistoryEntry {
  final String id;
  final DateTime dateTime;
  final List<Player> players;
  final List<BetItem> scoringItems;
  final List<BetItem> availableBetItems; // Tous les éléments disponibles
  final String winnerName; // Pourrait être "Égalité" ou contenir plusieurs noms
  final int winnerScore;
  final bool isTie; // Champ pour indiquer s'il y a égalité
  final GameHistoryStatus status; // Statut de la partie
  final int
      currentPlayerIndex; // Index du joueur actuel pour les parties en cours

  GameHistoryEntry({
    required this.id,
    required this.dateTime,
    required this.players,
    required this.scoringItems,
    required this.availableBetItems,
    required this.winnerName,
    required this.winnerScore,
    this.isTie = false, // Par défaut, il n'y a pas d'égalité
    this.status =
        GameHistoryStatus.completed, // Par défaut, la partie est terminée
    this.currentPlayerIndex = 0, // Par défaut, c'est le premier joueur
  });

  // Création à partir de JSON
  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      players:
          (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
      scoringItems: (json['scoringItems'] as List)
          .map((i) => BetItem.fromJson(i))
          .toList(),
      availableBetItems: json['availableBetItems'] != null
          ? (json['availableBetItems'] as List)
              .map((i) => BetItem.fromJson(i))
              .toList()
          : [], // Rétrocompatibilité pour les anciens enregistrements
      winnerName: json['winnerName'],
      winnerScore: json['winnerScore'],
      isTie: json['isTie'] ?? false,
      status: json['status'] != null
          ? GameHistoryStatus.values[json['status']]
          : GameHistoryStatus.completed, // Rétrocompatibilité
      currentPlayerIndex: json['currentPlayerIndex'] ?? 0, // Rétrocompatibilité
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'players': players.map((p) => p.toJson()).toList(),
      'scoringItems': scoringItems.map((i) => i.toJson()).toList(),
      'availableBetItems': availableBetItems.map((i) => i.toJson()).toList(),
      'winnerName': winnerName,
      'winnerScore': winnerScore,
      'isTie': isTie,
      'status': status.index,
      'currentPlayerIndex': currentPlayerIndex,
    };
  }

  // Format de date lisible
  String get formattedDate {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Récupérer la liste des noms des gagnants (utile en cas d'égalité)
  List<String> get winnerNames {
    if (!isTie) {
      return [winnerName];
    }

    // En cas d'égalité, trouver tous les joueurs ayant le même score que le gagnant
    return players
        .where((player) => player.score == winnerScore)
        .map((player) => player.name)
        .toList();
  }

  // Statut de la partie en texte lisible
  String get statusText {
    switch (status) {
      case GameHistoryStatus.inProgress:
        return 'Pari en cours';
      case GameHistoryStatus.waitingResults:
        return 'En attente des résultats';
      case GameHistoryStatus.completed:
        return 'Terminée';
    }
  }

  // Convertir l'entrée d'historique en objet Game pour continuer la partie
  Game toGame() {
    Game game = Game(
      availableBetItems: availableBetItems,
      players:
          List.from(players), // Copie pour éviter des problèmes de référence
      currentPlayerIndex: currentPlayerIndex,
    );

    // Configurer l'état de la partie en fonction de son statut dans l'historique
    switch (status) {
      case GameHistoryStatus.inProgress:
        game.state = GameState.playing;
        break;
      case GameHistoryStatus.waitingResults:
        game.state = GameState.scoring;
        break;
      case GameHistoryStatus.completed:
        game.state = GameState.finished;
        game.scoringItems = List.from(scoringItems);
        break;
    }

    return game;
  }
}
