class BetItem {
  final String id;
  final String name;
  final String description;
  bool isScoring =
      false; // Indique si l'élément rapporte des points à la fin de la partie

  BetItem({
    required this.id,
    required this.name,
    this.description = '',
    this.isScoring = false,
  });

  // Copie avec modification
  BetItem copyWith({
    String? id,
    String? name,
    String? description,
    bool? isScoring,
  }) {
    return BetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isScoring: isScoring ?? this.isScoring,
    );
  }

  // Conversion en Map pour le stockage JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isScoring': isScoring,
    };
  }

  // Création d'une instance à partir de données JSON
  factory BetItem.fromJson(Map<String, dynamic> json) {
    return BetItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isScoring: json['isScoring'] as bool? ?? false,
    );
  }
}
