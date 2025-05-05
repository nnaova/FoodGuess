import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/bet_item.dart';
import '../models/game.dart';

class GameSetupScreen extends StatefulWidget {
  final List<BetItem> availableBetItems;

  const GameSetupScreen({super.key, required this.availableBetItems});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final List<Player> _players = [];
  final TextEditingController _playerNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _players.add(
          Player(
            id: const Uuid().v4(),
            name: _playerNameController.text.trim(),
          ),
        );
      });
      _playerNameController.clear();
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
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
      ),
      body: Column(
        children: [
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
                        labelText: 'Nom du joueur',
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
          Expanded(
            child:
                _players.isEmpty
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
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(player.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removePlayer(index),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          _players.length >= 2
              ? FloatingActionButton.extended(
                onPressed: _startGame,
                label: const Text('Commencer la partie'),
                icon: const Icon(Icons.play_arrow),
              )
              : null,
    );
  }
}
