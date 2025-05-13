import 'package:flutter/material.dart';
import '../models/game_history_entry.dart';
import '../models/player.dart';
import '../models/bet_item.dart';

class GameHistoryDetailScreen extends StatelessWidget {
  final GameHistoryEntry entry;

  const GameHistoryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // Trier les joueurs par score décroissant
    final List<Player> sortedPlayers = List.from(entry.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la partie'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec infos de la partie
            _buildGameHeader(context),

            // Liste des joueurs et leurs scores
            _buildPlayersSection(context, sortedPlayers),

            // Éléments qui rapportaient des points
            _buildScoringItemsSection(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            // ignore: deprecated_member_use
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          // Icône différente selon le statut de la partie
          Icon(
            entry.status == GameHistoryStatus.completed
                ? Icons.emoji_events
                : (entry.status == GameHistoryStatus.waitingResults
                    ? Icons.pending_actions
                    : Icons.sports_esports),
            size: 60,
            color: entry.status == GameHistoryStatus.completed
                ? Colors.amber
                : Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            'Partie du ${entry.formattedDate}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          // Badge de statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(entry.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(entry.status),
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  entry.status == GameHistoryStatus.completed
                      ? (entry.isTie
                          ? 'Égalité: ${entry.winnerName}'
                          : 'Gagnant: ${entry.winnerName}')
                      : entry.statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${entry.players.length} joueurs ${entry.status == GameHistoryStatus.completed
                    ? '· ${entry.scoringItems.length} éléments gagnants'
                    : ''}',
            style: const TextStyle(color: Colors.white),
          ),

          // Bouton pour continuer une partie non terminée
          if (entry.status != GameHistoryStatus.completed)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _continueGame(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continuer la partie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection(BuildContext context, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Classement des joueurs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const Divider(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];

            // Calculer si ce joueur est gagnant
            final isWinner = player.score == entry.winnerScore;

            // Calculer la position réelle (en tenant compte des égalités)
            int displayPosition = 1;
            for (int i = 0; i < index; i++) {
              if (players[i].score > player.score) {
                displayPosition++;
              }
            }

            // Déterminer s'il y a égalité avec le joueur précédent
            final isTie = index > 0 && players[index - 1].score == player.score;

            return _buildPlayerRow(
              context,
              player,
              displayPosition,
              isWinner,
              isTie,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlayerRow(
    BuildContext context,
    Player player,
    int position,
    bool isWinner,
    bool isTie,
  ) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: isWinner ? Colors.amber : Colors.grey[300],
        child: Text(
          isTie ? '-' : '$position',
          style: TextStyle(
            color: isWinner ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        player.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isWinner ? Colors.amber[900] : null,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isWinner
              // ignore: deprecated_member_use
              ? Colors.amber.withOpacity(0.2)
              // ignore: deprecated_member_use
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${player.score} pts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWinner
                ? Colors.amber[900]
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      children: [
        if (player.betItemIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Éléments choisis:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: player.betItemIds.map((itemId) {
                    final item = _findBetItem(itemId);
                    final isScoring = item?.isScoring ?? false;

                    return Chip(
                      backgroundColor:
                          isScoring ? Colors.green[100] : Colors.grey[100],
                      label: Text(
                        item?.name != null
                            ? "${item!.name} (${item.points} pt${item.points > 1 ? 's' : ''})"
                            : 'Élément inconnu',
                        style: TextStyle(
                          color:
                              isScoring ? Colors.green[800] : Colors.grey[800],
                          fontWeight: isScoring ? FontWeight.w500 : null,
                        ),
                      ),
                      avatar: isScoring
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : const Icon(Icons.cancel, color: Colors.red),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScoringItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.fastfood,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Éléments gagnants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: entry.scoringItems.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun élément gagnant pour cette partie',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.scoringItems.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${item.name} (${item.points} pt${item.points > 1 ? 's' : ''})",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // Recherche un élément par son ID
  BetItem? _findBetItem(String itemId) {
    // D'abord chercher parmi les éléments gagnants
    try {
      return entry.scoringItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      // Ensuite, chercher dans tous les éléments disponibles de la partie
      try {
        return entry.availableBetItems.firstWhere((item) => item.id == itemId);
      } catch (e) {
        // Si toujours pas trouvé (pour la rétrocompatibilité avec les anciennes parties)
        return BetItem(id: itemId, name: 'Élément #$itemId', isScoring: false);
      }
    }
  }

  // Obtenir la couleur en fonction du statut de la partie
  Color _getStatusColor(GameHistoryStatus status) {
    switch (status) {
      case GameHistoryStatus.inProgress:
        return Colors.blue;
      case GameHistoryStatus.waitingResults:
        return Colors.orange;
      case GameHistoryStatus.completed:
        // ignore: deprecated_member_use
        return Colors.amber.withOpacity(0.8);
    }
  }

  // Obtenir l'icône en fonction du statut de la partie
  IconData _getStatusIcon(GameHistoryStatus status) {
    switch (status) {
      case GameHistoryStatus.inProgress:
        return Icons.sports_esports;
      case GameHistoryStatus.waitingResults:
        return Icons.pending_actions;
      case GameHistoryStatus.completed:
        return Icons.star;
    }
  }

  // Continuer une partie non terminée
  void _continueGame(BuildContext context) {
    // Convertir l'entrée d'historique en objet Game actif
    final game = entry.toGame();

    // Naviguer vers l'écran approprié en fonction du statut
    if (entry.status == GameHistoryStatus.inProgress) {
      // Aller à l'écran de jeu
      Navigator.pushNamed(
        context,
        '/game-play',
        arguments: {
          'game': game,
          'gameId': entry.id,
        },
      );
    } else if (entry.status == GameHistoryStatus.waitingResults) {
      // Aller à l'écran de scoring
      Navigator.pushNamed(
        context,
        '/game-scoring',
        arguments: {
          'game': game,
          'gameId': entry.id,
        },
      );
    }
  }
}
