import 'bet_item.dart';
import 'player.dart';

class GameHistoryEntry {
  final String id;
  final DateTime dateTime;
  final List<Player> players;
  final List<BetItem> scoringItems;
  final List<BetItem>
  availableBetItems; // Nouveau champ pour stocker tous les éléments disponibles
  final String winnerName; // Pourrait être "Égalité" ou contenir plusieurs noms
  final int winnerScore;
  final bool isTie; // Champ pour indiquer s'il y a égalité

  GameHistoryEntry({
    required this.id,
    required this.dateTime,
    required this.players,
    required this.scoringItems,
    required this.availableBetItems, // Nouveau paramètre requis
    required this.winnerName,
    required this.winnerScore,
    this.isTie = false, // Par défaut, il n'y a pas d'égalité
  });

  // Création à partir de JSON
  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      players:
          (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
      scoringItems:
          (json['scoringItems'] as List)
              .map((i) => BetItem.fromJson(i))
              .toList(),
      availableBetItems:
          json['availableBetItems'] != null
              ? (json['availableBetItems'] as List)
                  .map((i) => BetItem.fromJson(i))
                  .toList()
              : [], // Rétrocompatibilité pour les anciens enregistrements
      winnerName: json['winnerName'],
      winnerScore: json['winnerScore'],
      isTie:
          json['isTie'] ??
          false, // Utiliser false si non spécifié (rétrocompatibilité)
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
}
