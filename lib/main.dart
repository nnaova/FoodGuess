import 'package:flutter/material.dart';
import 'models/bet_item.dart';
import 'models/game.dart';
import 'services/bet_item_storage.dart';
import 'screens/home_screen.dart';
import 'screens/bet_items_screen.dart';
import 'screens/game_setup_screen.dart';
import 'screens/game_play_screen.dart';
import 'screens/game_scoring_screen.dart';
import 'screens/game_results_screen.dart';
import 'screens/game_history_screen.dart';

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
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.greenApple,
          onPrimary: Colors.black87,
          secondary: AppColors.orangeMango,
          onSecondary: Colors.white,
          error: AppColors.purpleGrape,
          onError: Colors.white,
          surface: AppColors.beigeLight,
          onSurface: Colors.black87,
          background: AppColors.beigeLight,
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
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
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
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/game-setup') {
          // Recharger les éléments pariables avant de configurer une partie
          _loadBetItems();
          return MaterialPageRoute(
            builder:
                (context) =>
                    _isLoading
                        ? const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        )
                        : GameSetupScreen(availableBetItems: _betItems),
          );
        } else if (settings.name == '/game-play') {
          final game = settings.arguments as Game;
          return MaterialPageRoute(
            builder: (context) => GamePlayScreen(game: game),
          );
        } else if (settings.name == '/game-scoring') {
          final game = settings.arguments as Game;
          return MaterialPageRoute(
            builder: (context) => GameScoringScreen(game: game),
          );
        } else if (settings.name == '/game-results') {
          final game = settings.arguments as Game;
          return MaterialPageRoute(
            builder: (context) => GameResultsScreen(game: game),
          );
        }
        return null;
      },
    );
  }
}
