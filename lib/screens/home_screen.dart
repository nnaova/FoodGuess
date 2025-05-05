import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration du style de la barre système pour l'harmoniser avec notre design
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête ludique avec logo et nom de l'app
              _buildHeader(context),

              // Section principale avec les cartes de jeu
              _buildGameCards(context),

              // Section statistiques du joueur
              _buildPlayerStats(context),

              // Section dernières activités
              _buildRecentActivity(context),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // En-tête avec logo et nom de l'application
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Logo ludique avec panier et aliments
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedFoodIcon(
                Icons.shopping_basket_rounded,
                65,
                Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 5),
              _buildAnimatedFoodIcon(Icons.egg_alt_rounded, 40, Colors.white),
              _buildAnimatedFoodIcon(
                Icons.apple,
                45,
                Theme.of(context).colorScheme.secondary.withOpacity(0.9),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nom de l'application avec style ludique
          Text(
            'FoodGuess',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 38,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(2, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Description du jeu
          Text(
            'Parie sur les aliments de la prochaine collecte !',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Section des cartes de jeu
  Widget _buildGameCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎮 Commence à jouer !',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),

          // Carte pour créer une nouvelle partie
          _buildPlayCard(
            context,
            title: 'Nouvelle partie',
            subtitle: 'Crée une session et invite tes amis',
            icon: Icons.add_circle_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            action: () => Navigator.pushNamed(context, '/game-setup'),
            isMain: true,
          ),

          const SizedBox(height: 16),

          // Deux cartes côte à côte
          Row(
            children: [
              // Carte pour gérer les éléments
              Expanded(
                child: _buildPlayCard(
                  context,
                  title: 'Gérer aliments',
                  subtitle: 'Ajoute ou modifie',
                  icon: Icons.fastfood_rounded,
                  color: Theme.of(context).colorScheme.error,
                  action: () => Navigator.pushNamed(context, '/bet-items'),
                ),
              ),
              const SizedBox(width: 16),
              // Carte pour rejoindre une partie
              Expanded(
                child: _buildPlayCard(
                  context,
                  title: 'Rejoindre',
                  subtitle: 'Par code invitation',
                  icon: Icons.group_add_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  action: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section de statistiques du joueur
  Widget _buildPlayerStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tes statistiques 🔥',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '12',
                'Parties jouées',
                Icons.sports_esports_rounded,
              ),
              _buildStatItem(
                context,
                '3',
                'Victoires',
                Icons.workspace_premium_rounded,
              ),
              _buildStatItem(
                context,
                '78%',
                'Précision',
                Icons.auto_graph_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section d'activité récente
  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Activités récentes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            context,
            icon: Icons.star_rounded,
            color: Theme.of(context).colorScheme.secondary,
            title: 'Bravo !',
            message: 'Tu as gagné une partie avec 7 prédictions correctes !',
            time: '1h',
          ),
          const Divider(height: 30),
          _buildActivityItem(
            context,
            icon: Icons.notifications_active_rounded,
            color: Theme.of(context).colorScheme.primary,
            title: 'Nouvelle collecte',
            message: '3 nouveaux aliments disponibles près de ton campus',
            time: '3h',
          ),
        ],
      ),
    );
  }

  // Élément d'activité
  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Il y a $time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Élément de statistique
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Carte de jeu
  Widget _buildPlayCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback action,
    bool isMain = false,
  }) {
    return Card(
      elevation: isMain ? 6 : 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(isMain ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isMain ? 60 : 50,
                height: isMain ? 60 : 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: isMain ? 32 : 26),
              ),
              SizedBox(height: isMain ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMain ? 22 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isMain ? 15 : 13,
                  color: Colors.grey[700],
                ),
              ),
              if (isMain) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jouer maintenant',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Icône alimentaire animée
  Widget _buildAnimatedFoodIcon(IconData icon, double size, Color color) {
    // L'animation serait implémentée avec un AnimationController en réalité
    // Ici on simule juste une légère rotation
    return Transform.rotate(
      angle:
          icon == Icons.apple
              ? -0.1
              : (icon == Icons.egg_alt_rounded ? 0.1 : 0),
      child: Icon(icon, size: size, color: color),
    );
  }
}
