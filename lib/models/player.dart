import 'bet_item.dart';

class Player {
  final String id;
  final String name;
  List<String> betItemIds =
      []; // IDs des éléments sur lesquels le joueur a parié
  int score = 0; // Score du joueur

  Player({
    required this.id,
    required this.name,
    List<String>? betItemIds,
    this.score = 0,
  }) : betItemIds = betItemIds != null ? List<String>.from(betItemIds) : [];

  // Ajouter un pari pour le joueur
  void addBet(String betItemId) {
    betItemIds.add(betItemId);
  }

  // Calculer le score du joueur
  void calculateScore(List<BetItem> scoringItems) {
    score = 0;
    for (final betItemId in betItemIds) {
      if (scoringItems.any((item) => item.id == betItemId && item.isScoring)) {
        score++;
      }
    }
  }

  // Copie avec modification
  Player copyWith({
    String? id,
    String? name,
    List<String>? betItemIds,
    int? score,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      betItemIds: betItemIds ?? List.from(this.betItemIds),
      score: score ?? this.score,
    );
  }

  // Conversion en Map pour le stockage JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'betItemIds': betItemIds, 'score': score};
  }

  // Création d'une instance à partir de données JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      betItemIds: (json['betItemIds'] as List<dynamic>).cast<String>(),
      score: json['score'],
    );
  }
}
