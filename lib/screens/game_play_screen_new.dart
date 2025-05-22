import 'package:flutter/material.dart';
import 'dart:async'; // Import pour utiliser Timer
import 'package:uuid/uuid.dart'; // Import pour générer des UUID
import '../models/game.dart';
import '../models/bet_item.dart';
import '../services/game_history_storage.dart'; // Import du service de stockage
import '../services/bet_item_storage.dart'; // Import pour sauvegarder les nouveaux éléments

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

  // Contrôleurs pour l'ajout d'un nouvel élément
  final TextEditingController _newItemNameController = TextEditingController();
  final TextEditingController _newItemDescController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BetItemStorage _betItemStorage = BetItemStorage();

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
    _newItemNameController.dispose();
    _newItemDescController.dispose();
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

  // Afficher une boîte de dialogue pour ajouter un nouvel élément
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un nouvel aliment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _newItemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'aliment',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newItemDescController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnelle)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _addNewItem(),
            child: const Text('Ajouter'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              final newItemId = _addNewItemAndGetId();
              if (newItemId != null) {
                _placeBet(newItemId);
              }
            },
            child: const Text('Ajouter et parier'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        buttonPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // Ajouter un nouvel élément et le sauvegarder
  void _addNewItem() {
    if (_formKey.currentState!.validate()) {
      // Créer un nouvel élément
      final newItem = BetItem(
        id: const Uuid().v4(),
        name: _newItemNameController.text.trim(),
        description: _newItemDescController.text.trim(),
        points: 1,
      );

      // Ajouter l'élément au jeu actuel
      setState(() {
        _game.addBetItem(newItem);
        _filteredItems = List.from(_game.availableItems);
      });

      // Sauvegarder le nouvel élément dans le stockage permanent
      _saveBetItemToPermanentStorage(newItem);

      // Effacer les champs et fermer la boîte de dialogue
      _newItemNameController.clear();
      _newItemDescController.clear();
      Navigator.pop(context);

      // Afficher une confirmation et proposer de parier sur l'élément
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${newItem.name} a été ajouté aux aliments disponibles'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Parier dessus',
            textColor: Colors.white,
            onPressed: () {
              _placeBet(newItem.id);
            },
          ),
        ),
      );
    }
  }

  // Ajouter un nouvel élément, le sauvegarder et retourner son ID pour parier dessus
  String? _addNewItemAndGetId() {
    if (_formKey.currentState!.validate()) {
      // Créer un nouvel élément
      final newItem = BetItem(
        id: const Uuid().v4(),
        name: _newItemNameController.text.trim(),
        description: _newItemDescController.text.trim(),
        points: 1,
      );

      // Ajouter l'élément au jeu actuel
      setState(() {
        _game.addBetItem(newItem);
        _filteredItems = List.from(_game.availableItems);
      });

      // Sauvegarder le nouvel élément dans le stockage permanent
      _saveBetItemToPermanentStorage(newItem);

      // Effacer les champs et fermer la boîte de dialogue
      _newItemNameController.clear();
      _newItemDescController.clear();
      Navigator.pop(
          context); // Afficher un message indiquant que l'élément a été ajouté
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newItem.name} a été ajouté et vous pariez dessus!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Retourner l'ID pour parier dessus
      return newItem.id;
    }
    return null;
  }

  // Sauvegarder le nouvel élément dans le stockage permanent
  Future<void> _saveBetItemToPermanentStorage(BetItem newItem) async {
    try {
      // Charger les éléments existants
      final existingItems = await _betItemStorage.loadBetItems();

      // Vérifier si l'élément existe déjà par son nom
      final nameExists = existingItems
          .any((item) => item.name.toLowerCase() == newItem.name.toLowerCase());

      if (!nameExists) {
        // Ajouter le nouvel élément et sauvegarder
        existingItems.add(newItem);
        await _betItemStorage.saveBetItems(existingItems);
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du nouvel élément: $e');
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
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
