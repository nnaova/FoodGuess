import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/bet_item.dart';
import '../services/game_history_storage.dart';

class GameResultsScreen extends StatefulWidget {
  final Game game;
  final String? gameId; // ID de la partie existante

  const GameResultsScreen({super.key, required this.game, this.gameId});

  @override
  State<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen> {
  final GameHistoryStorage _historyStorage = GameHistoryStorage();
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();
    // S'assurer que l'état du jeu est bien marqué comme terminé
    if (widget.game.state != GameState.finished) {
      widget.game.state = GameState.finished;
    }

    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    if (!_historySaved) {
      if (widget.gameId != null) {
        // Mettre à jour la partie existante avec le statut "completed"
        await _historyStorage.saveGameCompleted(widget.game,
            existingId: widget.gameId);
      } else {
        // Créer une nouvelle entrée pour la partie terminée
        await _historyStorage.saveGameCompleted(widget.game);
      }
      setState(() {
        _historySaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trier les joueurs par score décroissant
    final List<Player> sortedPlayers = List.from(widget.game.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats de la partie'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 120,
          ), // Espace pour les boutons flottants
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Carte du gagnant
                if (sortedPlayers.isNotEmpty)
                  _buildWinnerCard(sortedPlayers[0], context),

                // Liste des scores
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedPlayers.length,
                  itemBuilder: (ctx, index) {
                    final player = sortedPlayers[index];
                    return _buildPlayerResultCard(player, index, context);
                  },
                ),

                // Éléments qui rapportaient des points
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Éléments qui rapportaient des points:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in widget.game.scoringItems)
                            Chip(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              label: Text(
                                "${item.name} (${item.points} pt${item.points > 1 ? 's' : ''})",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              avatar: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              widget.game.resetGame();
              Navigator.pushReplacementNamed(
                context,
                '/game-play',
                arguments: widget.game,
              );
            },
            heroTag: 'new_game_same_players',
            label: const Text('Rejouer'),
            icon: const Icon(Icons.replay),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/game-history'),
            heroTag: 'view_history',
            label: const Text('Voir l\'historique'),
            icon: const Icon(Icons.history),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            heroTag: 'back_to_home',
            label: const Text('Retour à l\'accueil'),
            icon: const Icon(Icons.home),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(Player winner, BuildContext context) {
    final Color winnerBackgroundColor =
        Colors.amber[100] ?? Colors.amber.shade100;
    final Color winnerTextColor = Colors.amber[900] ?? Colors.amber.shade900;

    return Card(
      margin: const EdgeInsets.all(16),
      color: winnerBackgroundColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.amber,
              child: const Icon(
                Icons.emoji_events,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gagnant:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    winner.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: winnerTextColor,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '${winner.score} pts',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: winnerTextColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerResultCard(
    Player player,
    int index,
    BuildContext context,
  ) {
    // Trouver les éléments sur lesquels ce joueur a parié
    final List<BetItem> playerBetItems = widget.game.availableBetItems
        .where((item) => player.betItemIds.contains(item.id))
        .toList();

    final isTie =
        index > 0 && widget.game.players[index - 1].score == player.score;

    // Détermination des couleurs de fond et de texte pour meilleure lisibilité
    Color? cardBackgroundColor;
    Color titleTextColor = Colors.black87; // Couleur par défaut du texte titre

    if (index == 0) {
      cardBackgroundColor = Colors.amber[100];
      titleTextColor = Colors.amber[900] ?? Colors.amber.shade900;
    } else if (isTie && index <= 2) {
      cardBackgroundColor = Colors.grey[100];
      titleTextColor = Colors.grey[800] ?? Colors.grey.shade800;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardBackgroundColor,
      elevation: index == 0 ? 3 : 1,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: index == 0 ? Colors.amber : Colors.blueGrey,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: titleTextColor),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${player.score} pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Éléments choisis:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in playerBetItems)
                      Chip(
                        backgroundColor: item.isScoring
                            ? Colors.green[100]
                            : Colors.grey[100],
                        label: Text(
                          "${item.name} (${item.points} pt${item.points > 1 ? 's' : ''})",
                          style: TextStyle(
                            color: item.isScoring
                                ? Colors.green[800]
                                : Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        avatar: item.isScoring
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.cancel, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
