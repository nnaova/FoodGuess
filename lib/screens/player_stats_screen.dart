import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_history_entry.dart';
import '../services/game_history_storage.dart';

class PlayerStatsScreen extends StatefulWidget {
  final Player player;

  const PlayerStatsScreen({super.key, required this.player});

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  final GameHistoryStorage _historyStorage = GameHistoryStorage();
  List<GameHistoryEntry> _gameHistory = [];
  bool _isLoading = true;

  // Statistiques calculées
  int _gamesPlayed = 0;
  int _wins = 0;
  int _ties = 0;
  int _losses = 0;
  double _winRate = 0.0;
  double _tieRate = 0.0;
  double _lossRate = 0.0;
  double _avgScore = 0.0;
  int _totalScore = 0;
  int _highestScore = 0;
  String _mostPlayedWith = "Aucun";

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  Future<void> _loadGameHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await _historyStorage.loadGameHistory();

    // Filtrer l'historique pour ne garder que les parties où ce joueur est présent
    final playerGames =
        history.where((game) {
          return game.players.any((p) => p.id == widget.player.id);
        }).toList();

    setState(() {
      _gameHistory = playerGames;
      _calculateStats();
      _isLoading = false;
    });
  }

  void _calculateStats() {
    if (_gameHistory.isEmpty) {
      return;
    }

    // Nombre total de parties
    _gamesPlayed = _gameHistory.length;

    // Initialisation des compteurs
    _wins = 0;
    _ties = 0;
    _losses = 0;
    _totalScore = 0;
    _highestScore = 0;

    // Map pour compter les joueurs avec qui ce joueur a joué
    Map<String, int> playedWith = {};

    for (var game in _gameHistory) {
      // Récupérer le joueur dans cette partie spécifique
      final playerInGame = game.players.firstWhere(
        (p) => p.id == widget.player.id,
        orElse:
            () => Player(id: '', name: ''), // Cas improbable mais nécessaire
      );

      if (playerInGame.id.isEmpty) continue;

      // Comptabiliser le score
      _totalScore += playerInGame.score;
      if (playerInGame.score > _highestScore) {
        _highestScore = playerInGame.score;
      }

      // Déterminer si c'est une victoire, égalité ou défaite
      if (game.isTie) {
        // C'est une égalité, vérifier si notre joueur en fait partie
        if (game.winnerNames.contains(playerInGame.name)) {
          _ties++;
        } else {
          _losses++;
        }
      } else {
        // Victoire ou défaite
        if (game.winnerName == playerInGame.name) {
          _wins++;
        } else {
          _losses++;
        }
      }

      // Comptabiliser les joueurs avec qui ce joueur a joué
      for (var otherPlayer in game.players) {
        if (otherPlayer.id != widget.player.id) {
          playedWith[otherPlayer.name] =
              (playedWith[otherPlayer.name] ?? 0) + 1;
        }
      }
    }

    // Calculer les taux
    _winRate = _gamesPlayed > 0 ? (_wins / _gamesPlayed) * 100 : 0;
    _tieRate = _gamesPlayed > 0 ? (_ties / _gamesPlayed) * 100 : 0;
    _lossRate = _gamesPlayed > 0 ? (_losses / _gamesPlayed) * 100 : 0;
    _avgScore = _gamesPlayed > 0 ? _totalScore / _gamesPlayed : 0;

    // Déterminer le joueur avec qui ce joueur a le plus joué
    if (playedWith.isNotEmpty) {
      _mostPlayedWith =
          playedWith.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques de ${widget.player.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _gamesPlayed == 0
              ? _buildNoGamesView()
              : _buildStatsView(),
    );
  }

  Widget _buildNoGamesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.player.name} n\'a pas encore joué de partie.',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Les statistiques seront disponibles après quelques parties.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlayerHeader(),
          const SizedBox(height: 24),

          // Résumé des statistiques
          _buildStatsSummary(),
          const SizedBox(height: 24),

          // Graphique de performance
          _buildPerformanceChart(),
          const SizedBox(height: 24),

          // Historique des parties récentes
          _buildRecentGames(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPlayerHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.player.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.player.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_gamesPlayed partie${_gamesPlayed > 1 ? "s" : ""} jouée${_gamesPlayed > 1 ? "s" : ""}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Text(
                    'Joue le plus souvent avec $_mostPlayedWith',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé des performances',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Victoires',
                      '$_wins',
                      '${_winRate.toStringAsFixed(1)}%',
                      Colors.green,
                    ),
                    _buildStatColumn(
                      'Égalités',
                      '$_ties',
                      '${_tieRate.toStringAsFixed(1)}%',
                      Colors.amber,
                    ),
                    _buildStatColumn(
                      'Défaites',
                      '$_losses',
                      '${_lossRate.toStringAsFixed(1)}%',
                      Colors.red,
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Score total',
                      '$_totalScore pts',
                      '',
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildStatColumn(
                      'Score moyen',
                      '${_avgScore.toStringAsFixed(1)} pts',
                      'par partie',
                      Theme.of(context).colorScheme.secondary,
                    ),
                    _buildStatColumn(
                      'Meilleur score',
                      '$_highestScore pts',
                      '',
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques détaillées',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Répartition des résultats',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Expanded(
                        flex: _wins,
                        child: Container(color: Colors.green),
                      ),
                      Expanded(
                        flex: _ties,
                        child: Container(color: Colors.amber),
                      ),
                      Expanded(
                        flex: _losses,
                        child: Container(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem('Victoires', Colors.green),
                    _buildLegendItem('Égalités', Colors.amber),
                    _buildLegendItem('Défaites', Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                _buildBar(
                  label: 'Taux de victoire',
                  value: _winRate,
                  color: Colors.green,
                  suffix: '%',
                ),
                const SizedBox(height: 16),
                _buildBar(
                  label: 'Score moyen par partie',
                  value: _avgScore,
                  color: Theme.of(context).colorScheme.secondary,
                  suffix: ' pts',
                  total: _highestScore.toDouble(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required Color color,
    String suffix = '',
    double? total,
  }) {
    final displayValue = value.toStringAsFixed(1);
    final maxValue = total ?? 100.0;
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('$displayValue$suffix')],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentGames() {
    // Limiter l'affichage aux 5 dernières parties
    final recentGames = _gameHistory.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Parties récentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game-history');
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentGames.length,
          itemBuilder: (context, index) {
            final game = recentGames[index];
            final playerInGame = game.players.firstWhere(
              (p) => p.id == widget.player.id,
            );

            // Déterminer si le joueur a gagné cette partie
            bool isWinner = false;
            if (game.isTie) {
              isWinner = game.winnerNames.contains(playerInGame.name);
            } else {
              isWinner = game.winnerName == playerInGame.name;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isWinner ? Colors.amber : Colors.grey[300],
                  child: Icon(
                    isWinner ? Icons.emoji_events : Icons.sports_esports,
                    color: isWinner ? Colors.white : Colors.grey[700],
                  ),
                ),
                title: Text(
                  isWinner ? (game.isTie ? 'Égalité' : 'Victoire') : 'Défaite',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isWinner
                            ? (game.isTie
                                ? Colors.amber[800]
                                : Colors.green[700])
                            : Colors.red[700],
                  ),
                ),
                subtitle: Text(
                  'Score: ${playerInGame.score} pts · ${game.formattedDate}',
                ),
                trailing: Text(
                  '${game.players.length} joueurs',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  // Naviguer vers les détails de cette partie
                  Navigator.pushNamed(
                    context,
                    '/game-history-detail',
                    arguments: game,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
