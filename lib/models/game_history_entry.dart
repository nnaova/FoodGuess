import 'package:flutter/foundation.dart';
import 'bet_item.dart';
import 'player.dart';

class GameHistoryEntry {
  final String id;
  final DateTime dateTime;
  final List<Player> players;
  final List<BetItem> scoringItems;
  final String winnerName;
  final int winnerScore;

  GameHistoryEntry({
    required this.id,
    required this.dateTime,
    required this.players,
    required this.scoringItems,
    required this.winnerName,
    required this.winnerScore,
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
      winnerName: json['winnerName'],
      winnerScore: json['winnerScore'],
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'players': players.map((p) => p.toJson()).toList(),
      'scoringItems': scoringItems.map((i) => i.toJson()).toList(),
      'winnerName': winnerName,
      'winnerScore': winnerScore,
    };
  }

  // Format de date lisible
  String get formattedDate {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
