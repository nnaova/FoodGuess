import 'package:flutter/material.dart';
import 'dart:async'; // Import pour utiliser Timer
import '../models/game.dart';
import '../models/bet_item.dart';
import '../services/game_history_storage.dart';

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
  final GameHistoryStorage _historyStorage = GameHistoryStorage();

  @override
  void initState() {
    super.initState();
    _game = widget.game;

    // Charger les éléments précédemment sélectionnés si on reprend une partie
    _loadPreviousSelections();
  }

  // Méthode pour charger les sélections précédentes
  Future<void> _loadPreviousSelections() async {
    if (widget.gameId != null && _game.scoringItems.isNotEmpty) {
      setState(() {
        // Charger les IDs des éléments gagnants déjà sélectionnés
        _selectedItemIds.addAll(_game.scoringItems.map((item) => item.id));
      });
    }
  }

  // Timer pour éviter de sauvegarder trop souvent
  Timer? _saveDebounceTimer;

  void _toggleItemSelection(BetItem item) {
    setState(() {
      if (_selectedItemIds.contains(item.id)) {
        _selectedItemIds.remove(item.id);
      } else {
        _selectedItemIds.add(item.id);
      }
    });

    // Annuler le timer précédent s'il existe
    _saveDebounceTimer?.cancel();

    // Créer un nouveau timer qui sauvegarde après un délai
    // On attend 1 seconde après la dernière sélection avant de sauvegarder
    _saveDebounceTimer = Timer(const Duration(seconds: 1), () {
      // Sauvegarder l'état actuel des éléments sélectionnés
      _saveCurrentSelectionState();
    });
  }

  // Variable pour stocker l'ID de la partie (peut être mis à jour si nécessaire)
  String? _currentGameId;

  // Méthode pour sauvegarder l'état actuel des sélections
  Future<void> _saveCurrentSelectionState() async {
    // Créer une liste des éléments sélectionnés
    final selectedItems = _game.availableBetItems
        .where((item) => _selectedItemIds.contains(item.id))
        .toList();

    // On utilise la méthode setScoringItems temporairement pour mettre à jour
    // correctement les items de scoring dans la copie du jeu qu'on va sauvegarder
    final tempGame = Game(
      availableBetItems: _game.availableBetItems,
      players: _game.players,
      currentPlayerIndex: _game.currentPlayerIndex,
      state: GameState.scoring,
    );

    // Mettre à jour les items sélectionnés dans la copie temporaire et calculer les scores
    tempGame.setScoringItems(selectedItems);

    try {
      // Utiliser l'ID existant ou en créer un nouveau
      if (widget.gameId != null || _currentGameId != null) {
        final existingId = widget.gameId ?? _currentGameId;
        // Maintenant que les scores ont été calculés, on marque la partie comme terminée
        await _historyStorage.saveGameCompleted(tempGame,
            existingId: existingId);
      } else {
        // Si on n'a pas d'ID existant, en créer un nouveau et le stocker
        _currentGameId = await _historyStorage.saveGameCompleted(tempGame);
      }

      if (mounted) {
        // Feedback visuel discret pour indiquer que la sauvegarde a été faite
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sélections sauvegardées automatiquement'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // En cas d'erreur, on affiche un message mais on ne bloque pas l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Erreur lors de la sauvegarde des éléments sélectionnés'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _finishGame() async {
    // Récupérer les éléments sélectionnés
    final scoringItems = _game.availableBetItems
        .where((item) => _selectedItemIds.contains(item.id))
        .toList();

    // Mettre à jour l'état du jeu comme terminé
    _game.setScoringItems(scoringItems);
    _game.state =
        GameState.finished; // S'assurer que l'état est bien "finished"

    // Sauvegarder la partie comme terminée avant de quitter l'écran, que ce soit une mise à jour ou une nouvelle entrée
    String? gameId;
    if (widget.gameId != null) {
      await _historyStorage.saveGameCompleted(_game, existingId: widget.gameId);
      gameId = widget.gameId;
    } else if (_currentGameId != null) {
      await _historyStorage.saveGameCompleted(_game,
          existingId: _currentGameId);
      gameId = _currentGameId;
    } else {
      // Créer une nouvelle entrée si nécessaire
      gameId = await _historyStorage.saveGameCompleted(_game);
    }

    // Passer le jeu et l'ID à l'écran des résultats
    Navigator.pushReplacementNamed(
      // ignore: use_build_context_synchronously
      context,
      '/game-results',
      arguments: {
        'game': _game,
        'gameId': gameId,
      },
    );
  }

  @override
  void dispose() {
    // Annuler le timer s'il est actif
    _saveDebounceTimer?.cancel();

    // Sauvegarder l'état actuel avant de quitter
    if (_selectedItemIds.isNotEmpty) {
      // On utilise un appel synchrone pour s'assurer que la sauvegarde se fait avant la sortie
      _saveCurrentSelectionState();
    }
    super.dispose();
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
