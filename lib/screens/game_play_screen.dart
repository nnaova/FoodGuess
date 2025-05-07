import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/bet_item.dart';

class GamePlayScreen extends StatefulWidget {
  final Game game;

  const GamePlayScreen({super.key, required this.game});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late Game _game;
  final TextEditingController _searchController = TextEditingController();
  List<BetItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _game.startGame();
    _filteredItems = List.from(_game.availableItems);

    // Écouter les changements dans le champ de recherche
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrer les aliments en fonction du texte de recherche
  void _filterItems() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_game.availableItems);
      } else {
        _filteredItems =
            _game.availableItems.where((item) {
              return item.name.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _placeBet(String betItemId) {
    setState(() {
      _game.placeBet(betItemId);

      // Mettre à jour les éléments filtrés après avoir placé un pari
      _filterItems();

      // Si la partie est terminée, passer à l'écran de scoring
      if (_game.state == GameState.scoring) {
        _navigateToScoringScreen();
      }
    });
  }

  void _endGame() {
    setState(() {
      _game.endGame();
      _navigateToScoringScreen();
    });
  }

  void _navigateToScoringScreen() {
    Navigator.pushReplacementNamed(context, '/game-scoring', arguments: _game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partie en cours'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          TextButton(
            onPressed: _endGame,
            child: Text(
              'Terminer',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Informations sur le joueur actuel
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tour de ${_game.currentPlayer.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Éléments choisis: ${_game.currentPlayer.betItemIds.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher un élément',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Éléments disponibles pour parier
          Expanded(
            child:
                _filteredItems.isEmpty
                    ? const Center(
                      child: Text(
                        'Plus d\'éléments disponibles à choisir.\nTerminez la partie.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3 / 2,
                          ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (ctx, index) {
                        final item = _filteredItems[index];
                        return _buildBetItemCard(item);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetItemCard(BetItem item) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _placeBet(item.id),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (item.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    item.description,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
