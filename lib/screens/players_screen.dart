import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../services/player_storage.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  // Liste des joueurs
  List<Player> _players = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final PlayerStorage _storage = PlayerStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  // Charger les joueurs depuis le stockage
  Future<void> _loadPlayers() async {
    final players = await _storage.loadPlayers();
    setState(() {
      _players = players;
      _isLoading = false;
    });
  }

  // Sauvegarder les joueurs dans le stockage
  Future<void> _savePlayers() async {
    await _storage.savePlayers(_players);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _players.add(
          Player(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
          ),
        );
      });
      _savePlayers(); // Sauvegarder après ajout
      _nameController.clear();
      Navigator.pop(context);
    }
  }

  void _editPlayer(Player player, int index) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _players[index] = Player(
          id: player.id,
          name: _nameController.text.trim(),
          betItemIds: player.betItemIds,
          score: player.score,
        );
      });
      _savePlayers(); // Sauvegarder après modification
      _nameController.clear();
      Navigator.pop(context);
    }
  }

  void _deletePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
    _savePlayers(); // Sauvegarder après suppression
  }

  void _showAddEditDialog({Player? player, int? index}) {
    if (player != null) {
      _nameController.text = player.name;
    } else {
      _nameController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          player == null ? 'Ajouter un joueur' : 'Modifier le joueur',
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (player == null) {
                _addPlayer();
              } else {
                _editPlayer(player, index!);
              }
            },
            child: Text(player == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joueurs'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun joueur enregistré.\nAjoutez des joueurs en appuyant sur +',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (ctx, index) {
                    final player = _players[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(player.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditDialog(
                              player: player,
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePlayer(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}