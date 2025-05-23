import 'package:flutter/material.dart';
import 'models/bet_item.dart';
import 'models/game.dart';
import 'models/game_history_entry.dart'; // Nouvel import
import 'services/bet_item_storage.dart';
import 'screens/home_screen.dart';
import 'screens/bet_items_screen.dart';
import 'screens/game_setup_screen.dart';
import 'screens/game_play_screen.dart';
import 'screens/game_scoring_screen.dart';
import 'screens/game_results_screen.dart';
import 'screens/game_history_screen.dart';
import 'screens/game_history_detail_screen.dart'; // Nouvel import
import 'screens/players_screen.dart';
import 'screens/player_comparison_screen.dart';
import 'screens/data_export_import_screen.dart'; // Nouvel import

// Nouvelles couleurs de la charte graphique FoodGuess
class AppColors {
  static const Color greenApple = Color(
    0xFFA3E635,
  ); // 🍏 Vert pomme - nature et vitalité
  static const Color orangeMango = Color(
    0xFFFF9F1C,
  ); // 🍊 Orange mangue - fun et attention
  static const Color purpleGrape = Color(
    0xFF9D4EDD,
  ); // 🍇 Violet raisin - originalité et jeu
  static const Color beigeLight = Color(
    0xFFFFF7E1,
  ); // 🧂 Beige clair - douceur et équilibre
  static const Color brownHazelnut = Color(
    0xFFAA7C5D,
  ); // 🍞 Brun noisette - rappel alimentaire
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Liste des éléments pariables (chargée depuis le stockage)
  List<BetItem> _betItems = [];
  bool _isLoading = true;
  final BetItemStorage _storage = BetItemStorage();

  @override
  void initState() {
    super.initState();
    _loadBetItems();
  }

  // Charger les éléments pariables depuis le stockage
  Future<void> _loadBetItems() async {
    final items = await _storage.loadBetItems();
    setState(() {
      _betItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodGuess',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.greenApple,
          onPrimary: Colors.black87,
          secondary: AppColors.orangeMango,
          onSecondary: Colors.white,
          error: AppColors.purpleGrape,
          onError: Colors.white,
          surface: AppColors.beigeLight,
          onSurface: Colors.black87,
          // ignore: deprecated_member_use
          background: AppColors.beigeLight,
          // ignore: deprecated_member_use
          onBackground: Colors.black87,
        ),
        // Utilisation de polices système à la place des polices personnalisées
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontWeight: FontWeight.w600),
        ),
        // Éléments UI très arrondis pour l'aspect ludique
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          shadowColor: Colors.black26,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.orangeMango,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 4,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/bet-items': (context) => const BetItemsScreen(),
        '/game-history': (context) => const GameHistoryScreen(),
        '/players': (context) => const PlayersScreen(),
        '/player-comparison': (context) => const PlayerComparisonScreen(),
        '/data-export-import': (context) => const DataExportImportScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/game-setup') {
          // Recharger les éléments pariables avant de configurer une partie
          _loadBetItems();
          return MaterialPageRoute(
            builder: (context) => _isLoading
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : GameSetupScreen(availableBetItems: _betItems),
          );
        } else if (settings.name == '/game-play') {
          // Le jeu peut être passé directement ou avec un ID de partie existante
          if (settings.arguments is Game) {
            final game = settings.arguments as Game;
            return MaterialPageRoute(
              builder: (context) => GamePlayScreen(game: game),
            );
          } else if (settings.arguments is Map) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => GamePlayScreen(
                game: args['game'] as Game,
                gameId: args['gameId'] as String?,
              ),
            );
          }
        } else if (settings.name == '/game-scoring') {
          // Accepter soit un Game, soit un Map avec game et gameId
          if (settings.arguments is Game) {
            final game = settings.arguments as Game;
            return MaterialPageRoute(
              builder: (context) => GameScoringScreen(game: game),
            );
          } else if (settings.arguments is Map) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => GameScoringScreen(
                game: args['game'] as Game,
                gameId: args['gameId'] as String?,
              ),
            );
          }
        } else if (settings.name == '/game-results') {
          // Accepter soit un Game, soit un Map avec game et gameId
          if (settings.arguments is Game) {
            final game = settings.arguments as Game;
            return MaterialPageRoute(
              builder: (context) => GameResultsScreen(game: game),
            );
          } else if (settings.arguments is Map) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => GameResultsScreen(
                game: args['game'] as Game,
                gameId: args['gameId'] as String?,
              ),
            );
          }
        } else if (settings.name == '/game-history-detail') {
          final entry = settings.arguments as GameHistoryEntry;
          return MaterialPageRoute(
            builder: (context) => GameHistoryDetailScreen(entry: entry),
          );
        }
        return null;
      },
    );
  }
}
