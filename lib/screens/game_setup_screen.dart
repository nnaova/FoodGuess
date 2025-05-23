import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/bet_item.dart';
import '../models/game.dart';
import '../services/player_storage.dart';
import '../screens/players_screen.dart';

class GameSetupScreen extends StatefulWidget {
  final List<BetItem> availableBetItems;

  const GameSetupScreen({super.key, required this.availableBetItems});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final List<Player> _players = [];
  List<Player> _availablePlayers = [];
  final TextEditingController _playerNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final PlayerStorage _playerStorage = PlayerStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
    });

    final players = await _playerStorage.loadPlayers();

    setState(() {
      _availablePlayers = players;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _addPlayer() async {
    if (_formKey.currentState!.validate()) {
      final newPlayerName = _playerNameController.text.trim();

      // Vérifier si un joueur avec le même nom existe déjà dans la liste disponible
      final existingPlayerWithSameName = _availablePlayers
          .where((player) =>
              player.name.toLowerCase() == newPlayerName.toLowerCase())
          .toList();

      // Si un joueur avec ce nom existe déjà, proposer de l'utiliser plutôt
      if (existingPlayerWithSameName.isNotEmpty) {
        final shouldUseExisting = await _showPlayerAlreadyExistsDialog(
            existingPlayerWithSameName.first);
        if (shouldUseExisting) {
          _addExistingPlayer(existingPlayerWithSameName.first);
          _playerNameController.clear();
          return;
        }
      }

      // Créer un nouveau joueur
      final newPlayer = Player(
        id: const Uuid().v4(),
        name: newPlayerName,
      );

      setState(() {
        _players.add(newPlayer);
      });

      // Ajouter le joueur à la liste des joueurs disponibles
      setState(() {
        _availablePlayers.add(newPlayer);
      });

      // Sauvegarder le joueur dans le stockage permanent
      await _saveNewPlayer(newPlayer);

      _playerNameController.clear();

      // Afficher une confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$newPlayerName a été ajouté à la liste des joueurs'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Sauvegarder un nouveau joueur dans le stockage permanent
  Future<void> _saveNewPlayer(Player newPlayer) async {
    try {
      // Ajouter le joueur à la liste existante et sauvegarder
      final updatedPlayerList = List<Player>.from(_availablePlayers);
      await _playerStorage.savePlayers(updatedPlayerList);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du nouveau joueur: $e');
    }
  }

  // Affiche une boîte de dialogue pour demander si l'utilisateur veut utiliser un joueur existant
  Future<bool> _showPlayerAlreadyExistsDialog(Player existingPlayer) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Joueur existant'),
        content: Text(
            'Un joueur nommé "${existingPlayer.name}" existe déjà. Voulez-vous l\'ajouter à la partie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Créer nouveau'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Utiliser existant'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _addExistingPlayer(Player player) {
    // Vérifier si le joueur est déjà sélectionné
    if (_players.any((p) => p.id == player.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${player.name} est déjà dans la partie'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      // Créer une nouvelle instance du joueur pour cette partie
      _players.add(Player(id: player.id, name: player.name));
    });
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _navigateToPlayerManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayersScreen()),
    );
    // Recharger la liste des joueurs après retour de l'écran de gestion
    _loadPlayers();
  }

  void _startGame() {
    if (_players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous devez ajouter au moins 2 joueurs pour commencer une partie',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.availableBetItems.length < _players.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Il doit y avoir au moins autant d\'éléments pariables que de joueurs',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final game = Game(
      availableBetItems: widget.availableBetItems,
      players: _players,
    );

    Navigator.pushNamed(context, '/game-play', arguments: game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration de la partie'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Gérer les joueurs',
            onPressed: _navigateToPlayerManagement,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Section de sélection des joueurs existants
                if (_availablePlayers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Joueurs disponibles',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availablePlayers.length,
                              itemBuilder: (ctx, index) {
                                final player = _availablePlayers[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: InkWell(
                                    onTap: () => _addExistingPlayer(player),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          child: Text(
                                            player.name[0].toUpperCase(),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(player.name),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Section d'ajout manuel de joueur
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _playerNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nouveau joueur',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer un nom de joueur';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _addPlayer,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                // Liste des joueurs de la partie
                Expanded(
                  child: _players.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun joueur ajouté.\nAjoutez des joueurs pour commencer une partie.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _players.length,
                          itemBuilder: (ctx, index) {
                            final player = _players[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(player.name),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removePlayer(index),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _players.length >= 2
          ? FloatingActionButton.extended(
              onPressed: _startGame,
              label: const Text('Commencer la partie'),
              icon: const Icon(Icons.play_arrow),
            )
          : null,
    );
  }
}
