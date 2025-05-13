import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/bet_item.dart';

class GameScoringScreen extends StatefulWidget {
  final Game game;
  final String? gameId; // ID de la partie en cours

  const GameScoringScreen({super.key, required this.game, this.gameId});

  @override
  State<GameScoringScreen> createState() => _GameScoringScreenState();
}

class _GameScoringScreenState extends State<GameScoringScreen> {
  late final Game _game;
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  void _toggleItemSelection(BetItem item) {
    setState(() {
      if (_selectedItemIds.contains(item.id)) {
        _selectedItemIds.remove(item.id);
      } else {
        _selectedItemIds.add(item.id);
      }
    });
  }

  void _finishGame() {
    // Récupérer les éléments sélectionnés
    final scoringItems = _game.availableBetItems
        .where((item) => _selectedItemIds.contains(item.id))
        .toList();

    _game.setScoringItems(scoringItems);

    // Passer le jeu et l'ID à l'écran des résultats
    Navigator.pushReplacementNamed(
      context,
      '/game-results',
      arguments: {
        'game': _game,
        'gameId': widget.gameId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection des éléments gagnants'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sélectionnez les éléments qui rapportent des points',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
              ),
              itemCount: _game.availableBetItems.length,
              itemBuilder: (ctx, index) {
                final item = _game.availableBetItems[index];
                final isSelected = _selectedItemIds.contains(item.id);

                return Card(
                  elevation: 4,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: InkWell(
                    onTap: () => _toggleItemSelection(item),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors
                                      .white // Couleur blanche pour un meilleur contraste
                                  : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${item.points} pt${item.points > 1 ? 's' : ''}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                          ),
                          if (item.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primary
                                      : null,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _finishGame,
        label: const Text('Terminer et voir les résultats'),
        icon: const Icon(Icons.celebration),
      ),
    );
  }
}
