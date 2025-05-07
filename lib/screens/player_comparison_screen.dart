import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_history_entry.dart';
import '../services/game_history_storage.dart';
import '../services/player_storage.dart';

class PlayerComparisonScreen extends StatefulWidget {
  const PlayerComparisonScreen({super.key});

  @override
  State<PlayerComparisonScreen> createState() => _PlayerComparisonScreenState();
}

class _PlayerComparisonScreenState extends State<PlayerComparisonScreen> {
  final PlayerStorage _playerStorage = PlayerStorage();
  final GameHistoryStorage _historyStorage = GameHistoryStorage();

  List<Player> _availablePlayers = [];
  List<GameHistoryEntry> _gameHistory = [];
  bool _isLoading = true;

  Player? _playerA;
  Player? _playerB;

  // Statistiques
  int _gamesPlayed = 0;
  int _playerAWins = 0;
  int _playerBWins = 0;
// Nouvelle variable pour les égalités
  double _playerAWinPercentage = 0;
  double _playerBWinPercentage = 0;
  double _tiePercentage = 0; // Nouvelle variable pour le pourcentage d'égalités
  double _playerAAvgScore = 0;
  double _playerBAvgScore = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final players = await _playerStorage.loadPlayers();
    final history = await _historyStorage.loadGameHistory();

    setState(() {
      _availablePlayers = players;
      _gameHistory = history;
      _isLoading = false;
    });
  }

  void _calculateStats() {
    if (_playerA == null || _playerB == null) {
      _resetStats();
      return;
    }

    // Filtrer l'historique pour ne garder que les parties où les deux joueurs sont présents
    final commonGames =
        _gameHistory.where((game) {
          final playerIds = game.players.map((p) => p.id).toList();
          return playerIds.contains(_playerA!.id) &&
              playerIds.contains(_playerB!.id);
        }).toList();

    // Si aucune partie commune, réinitialiser les stats
    if (commonGames.isEmpty) {
      _resetStats();
      setState(() {
        _gamesPlayed = 0;
      });
      return;
    }

    // Calculer les statistiques
    int playerAWins = 0;
    int playerBWins = 0;
    int ties = 0; // Compteur pour les égalités
    int totalPlayerAScore = 0;
    int totalPlayerBScore = 0;

    for (final game in commonGames) {
      // Rechercher les joueurs dans cette partie spécifique
      final playerAInGame = game.players.firstWhere(
        (p) => p.id == _playerA!.id,
      );
      final playerBInGame = game.players.firstWhere(
        (p) => p.id == _playerB!.id,
      );

      // Ajouter les scores
      totalPlayerAScore += playerAInGame.score;
      totalPlayerBScore += playerBInGame.score;

      if (game.isTie) {
        // Cas d'égalité entre au moins deux joueurs
        // Vérifier si nos deux joueurs font partie des gagnants
        final isPlayerATied = game.winnerNames.contains(playerAInGame.name);
        final isPlayerBTied = game.winnerNames.contains(playerBInGame.name);

        if (isPlayerATied && isPlayerBTied) {
          // Les deux joueurs sont à égalité
          ties++;
        } else if (isPlayerATied) {
          playerAWins++;
        } else if (isPlayerBTied) {
          playerBWins++;
        }
        // Sinon, aucun des deux n'est gagnant
      } else {
        // Cas normal (un seul gagnant)
        if (game.winnerName == playerAInGame.name) {
          playerAWins++;
        } else if (game.winnerName == playerBInGame.name) {
          playerBWins++;
        }
        // Sinon, c'est un autre joueur qui a gagné
      }
    }

    // Calculer les pourcentages et moyennes
    final gamesPlayed = commonGames.length;
    final playerAWinPercentage =
        gamesPlayed > 0 ? (playerAWins / gamesPlayed) * 100 : 0;
    final playerBWinPercentage =
        gamesPlayed > 0 ? (playerBWins / gamesPlayed) * 100 : 0;
    final tiePercentage = gamesPlayed > 0 ? (ties / gamesPlayed) * 100 : 0;
    final playerAAvgScore =
        gamesPlayed > 0 ? totalPlayerAScore / gamesPlayed : 0;
    final playerBAvgScore =
        gamesPlayed > 0 ? totalPlayerBScore / gamesPlayed : 0;

    setState(() {
      _gamesPlayed = gamesPlayed;
      _playerAWins = playerAWins;
      _playerBWins = playerBWins;
// Nouvelle variable pour les égalités
      _playerAWinPercentage = playerAWinPercentage.toDouble();
      _playerBWinPercentage = playerBWinPercentage.toDouble();
      _tiePercentage =
          tiePercentage
              .toDouble(); // Nouvelle variable pour le pourcentage d'égalités
      _playerAAvgScore = playerAAvgScore.toDouble();
      _playerBAvgScore = playerBAvgScore.toDouble();
    });
  }

  void _resetStats() {
    setState(() {
      _playerAWins = 0;
      _playerBWins = 0;
// Réinitialiser les égalités
      _playerAWinPercentage = 0;
      _playerBWinPercentage = 0;
      _tiePercentage = 0; // Réinitialiser le pourcentage d'égalités
      _playerAAvgScore = 0;
      _playerBAvgScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparaison des joueurs'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _availablePlayers.length < 2
              ? const Center(
                child: Text(
                  'Il faut au moins 2 joueurs dans la base de données pour faire une comparaison',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélection des joueurs
                    _buildPlayerSelectionSection(),

                    const SizedBox(height: 24),

                    // Résultats de la comparaison
                    if (_playerA != null && _playerB != null)
                      _buildComparisonResults(),
                  ],
                ),
              ),
    );
  }

  Widget _buildPlayerSelectionSection() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionnez les joueurs à comparer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Sélection du joueur A
            _buildPlayerDropdown(
              label: 'Joueur A',
              value: _playerA,
              onChanged: (Player? player) {
                setState(() {
                  _playerA = player;
                });
                _calculateStats();
              },
            ),

            const SizedBox(height: 16),

            // Sélection du joueur B
            _buildPlayerDropdown(
              label: 'Joueur B',
              value: _playerB,
              onChanged: (Player? player) {
                setState(() {
                  _playerB = player;
                });
                _calculateStats();
              },
            ),

            if (_playerA != null &&
                _playerB != null &&
                _playerA!.id == _playerB!.id)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Veuillez sélectionner deux joueurs différents',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerDropdown({
    required String label,
    required Player? value,
    required Function(Player?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<Player>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items:
              _availablePlayers.map((player) {
                return DropdownMenuItem<Player>(
                  value: player,
                  child: Text(player.name),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildComparisonResults() {
    // Vérifier si les deux joueurs sont différents
    if (_playerA!.id == _playerB!.id) {
      return const SizedBox.shrink();
    }

    // Vérifier s'il y a des parties communes
    if (_gamesPlayed == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Aucune partie commune trouvée pour ${_playerA!.name} et ${_playerB!.name}',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informations générales
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistiques communes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Parties jouées ensemble: $_gamesPlayed',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Graphiques de comparaison
        Row(
          children: [
            // Pourcentage de victoire
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pourcentage de victoire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildComparisonBar(
                        label: _playerA!.name,
                        value: _playerAWinPercentage,
                        color: Colors.blue,
                        total: 100,
                        suffix: '%',
                      ),
                      const SizedBox(height: 8),
                      _buildComparisonBar(
                        label: _playerB!.name,
                        value: _playerBWinPercentage,
                        color: Colors.red,
                        total: 100,
                        suffix: '%',
                      ),
                      const SizedBox(height: 8),
                      _buildComparisonBar(
                        label: 'Égalités',
                        value: _tiePercentage,
                        color: Colors.green,
                        total: 100,
                        suffix: '%',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Moyenne de score par partie
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Moyenne de points par partie',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildComparisonBar(
                  label: _playerA!.name,
                  value: _playerAAvgScore,
                  color: Colors.blue,
                  total:
                      _playerAAvgScore > _playerBAvgScore
                          ? _playerAAvgScore
                          : _playerBAvgScore,
                  suffix: ' pts',
                ),
                const SizedBox(height: 8),
                _buildComparisonBar(
                  label: _playerB!.name,
                  value: _playerBAvgScore,
                  color: Colors.red,
                  total:
                      _playerAAvgScore > _playerBAvgScore
                          ? _playerAAvgScore
                          : _playerBAvgScore,
                  suffix: ' pts',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Tableau récapitulatif des statistiques
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Résumé des statistiques',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Nombre de parties gagnées',
                  '$_playerAWins',
                  '$_playerBWins',
                ),
                _buildStatRow(
                  'Pourcentage de victoire',
                  '${_playerAWinPercentage.toStringAsFixed(1)}%',
                  '${_playerBWinPercentage.toStringAsFixed(1)}%',
                ),
                _buildStatRow(
                  'Pourcentage d\'égalités',
                  '${_tiePercentage.toStringAsFixed(1)}%',
                  '-',
                ),
                _buildStatRow(
                  'Moyenne de points par partie',
                  '${_playerAAvgScore.toStringAsFixed(2)} pts',
                  '${_playerBAvgScore.toStringAsFixed(2)} pts',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonBar({
    required String label,
    required double value,
    required Color color,
    required double total,
    required String suffix,
  }) {
    final percentage = total > 0 ? (value / total) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('${value.toStringAsFixed(1)}$suffix')],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String valueA, String valueB) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(
            flex: 2,
            child: Text(
              valueA,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              valueB,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
