# FoodGuess

FoodGuess est une application ludique qui permet de parier sur les aliments qui seront présents lors d'une prochaine collecte alimentaire.

## Fonctionnalités

- **Nouvelle partie**: Créez une session et jouez avec vos amis
- **Gestion des aliments**: Ajoutez ou modifiez les éléments disponibles pour parier
- **Historique**: Consultez les parties précédentes et les résultats détaillés
- **Statistiques**: Comparez les performances des joueurs
- **Gestion des joueurs**: Créez et modifiez les profils des joueurs

## Comment jouer

1. Commencez par créer une liste d'aliments dans la section "Gérer aliments"
2. Ajoutez des joueurs dans la section "Joueurs"
3. Démarrez une nouvelle partie et sélectionnez les joueurs participants
4. Chaque joueur choisit à son tour un aliment sur lequel parier
5. À la fin, sélectionnez les aliments qui étaient réellement présents lors de la collecte
6. Les joueurs marquent des points pour chaque prédiction correcte

## Installation et développement

### Prérequis

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.7.2 ou supérieure)
- [Dart](https://dart.dev/get-dart) (version SDK 3.7.2 ou supérieure)
- Un éditeur de code (VS Code, Android Studio ou IntelliJ IDEA recommandé)
- Git

### Clone du projet

```bash
# Cloner le dépôt
git clone https://github.com/votre-username/foodguess.git
cd foodguess

# Installer les dépendances
flutter pub get
```

### Exécution du projet

```bash
# Vérifier que votre environnement est correctement configuré
flutter doctor

# Lancer l'application en mode debug
flutter run

# Ou spécifier une plateforme cible
flutter run -d chrome      # Pour le web
flutter run -d android     # Pour Android
flutter run -d ios         # Pour iOS (nécessite un Mac)
flutter run -d windows     # Pour Windows
flutter run -d macos       # Pour macOS (nécessite un Mac)
flutter run -d linux       # Pour Linux
```

### Construction pour la production

```bash
# Construire une version release pour Android
flutter build apk

# Construire pour iOS
flutter build ios

# Construire pour le web
flutter build web

# Construire pour desktop
flutter build windows
flutter build macos
flutter build linux
```

### Structure du projet

```
lib/
  ├── main.dart                    # Point d'entrée de l'application
  ├── models/                      # Modèles de données
  ├── screens/                     # Écrans de l'application
  ├── services/                    # Services pour la gestion des données
  └── theme/                       # Configuration du thème
```

### Contribution

1. Créez une branche pour votre fonctionnalité (`git checkout -b feature/nouvelle-fonctionnalite`)
2. Committez vos changements (`git commit -m 'Ajout d'une nouvelle fonctionnalité'`)
3. Poussez vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
4. Ouvrez une Pull Request

## Versions

L'application est actuellement en version 1.0 (Mai 2025)

## Crédits

- **Concept & Design**: Alexandre Giordana
- **Développement**: Alexandre Giordana
