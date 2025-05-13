import 'package:flutter/material.dart';
import 'dart:async'; // Import pour utiliser Timer
import '../models/game.dart';
import '../models/bet_item.dart';
import '../services/game_history_storage.dart'; // Import du service de stockage

class GamePlayScreen extends StatefulWidget {
  final Game game;
  // Pour reprendre une partie existante
  final String? gameId;

  const GamePlayScreen({super.key, required this.game, this.gameId});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late Game _game;
  final TextEditingController _searchController = TextEditingController();
  List<BetItem> _filteredItems = [];
  final GameHistoryStorage _historyStorage =
      GameHistoryStorage(); // Service de stockage
  String? _gameId; // ID de la partie en cours

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _gameId = widget.gameId; // Récupérer l'ID si on reprend une partie
    _game.startGame();
    _filteredItems = List.from(_game.availableItems);

    // Écouter les changements dans le champ de recherche
    _searchController.addListener(_filterItems);

    // Si c'est une nouvelle partie, la sauvegarder immédiatement
    if (_gameId == null) {
      // Utiliser Future.microtask pour exécuter du code asynchrone après initState
      Future.microtask(() => _saveGameInProgress());
    }
  }

  @override
  void dispose() {
    // Annuler le timer s'il est actif
    _saveDebounceTimer?.cancel();

    // Sauvegarder l'état actuel avant de quitter
    if (_game.state == GameState.playing) {
      // Sauvegarde synchrone pour s'assurer qu'elle se produit avant de quitter
      _saveGameInProgress();
    }
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
        _filteredItems = _game.availableItems.where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Timer pour éviter de sauvegarder trop souvent
  Timer? _saveDebounceTimer;

  void _placeBet(String betItemId) {
    setState(() {
      _game.placeBet(betItemId);

      // Mettre à jour les éléments filtrés après avoir placé un pari
      _filterItems();
    });

    // Si la partie est terminée, passer à l'écran de scoring
    if (_game.state == GameState.scoring) {
      _navigateToScoringScreen();
    } else {
      // Annuler le timer précédent s'il existe
      _saveDebounceTimer?.cancel();

      // Créer un nouveau timer qui sauvegarde après un délai
      _saveDebounceTimer = Timer(const Duration(seconds: 1), () {
        // Sauvegarder la partie en cours
        _saveGameInProgress();
      });
    }
  }

  void _endGame() async {
    setState(() {
      _game.endGame();
    });

    // Sauvegarder la partie comme "en attente des résultats"
    if (_gameId != null) {
      // Mettre à jour la partie existante
      await _historyStorage.saveGameWaitingResults(_game, existingId: _gameId);
    } else {
      // Créer une nouvelle entrée
      _gameId = await _historyStorage.saveGameWaitingResults(_game);
    }

    _navigateToScoringScreen();
  }

  void _navigateToScoringScreen() {
    // Passer le jeu et l'ID à l'écran de scoring
    Navigator.pushReplacementNamed(
      context,
      '/game-scoring',
      arguments: {
        'game': _game,
        'gameId': _gameId,
      },
    );
  }

  Future<void> _saveGameInProgress() async {
    try {
      // La méthode saveGameInProgress retourne un Future<String>
      _gameId =
          await _historyStorage.saveGameInProgress(_game, existingId: _gameId);

      if (mounted) {
        // Feedback visuel discret pour indiquer que la sauvegarde a été faite
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pari sauvegardé automatiquement'),
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
            content: Text('Erreur lors de la sauvegarde du pari'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            child: _filteredItems.isEmpty
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
