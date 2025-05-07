class BetItem {
  final String id;
  final String name;
  final String description;
  bool isScoring =
      false; // Indique si l'élément rapporte des points à la fin de la partie
  int points = 1; // Nombre de points que vaut cet élément (par défaut: 1)

  BetItem({
    required this.id,
    required this.name,
    this.description = '',
    this.isScoring = false,
    this.points = 1, // Valeur par défaut: 1 point
  });

  // Copie avec modification
  BetItem copyWith({
    String? id,
    String? name,
    String? description,
    bool? isScoring,
    int? points,
  }) {
    return BetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isScoring: isScoring ?? this.isScoring,
      points: points ?? this.points,
    );
  }

  // Conversion en Map pour le stockage JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isScoring': isScoring,
      'points': points,
    };
  }

  // Création d'une instance à partir de données JSON
  factory BetItem.fromJson(Map<String, dynamic> json) {
    return BetItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      isScoring: json['isScoring'] ?? false,
      points: json['points'] ?? 1, // Valeur par défaut si non spécifié: 1 point
    );
  }
}
