# FoodGuess

FoodGuess est une application ludique qui permet de parier sur les aliments qui seront présents lors d'un prochain arrivage alimentaire.

## Fonctionnalités

- **Nouvelle partie**: Créez une session et jouez avec vos amis
- **Gestion des aliments**: Ajoutez ou modifiez les éléments disponibles pour parier, définissez leur valeur en points
- **Historique**: Consultez les parties précédentes et les résultats détaillés
- **Statistiques**: Comparez les performances des joueurs et consultez les statistiques individuelles détaillées
- **Gestion des joueurs**: Créez et modifiez les profils des joueurs

## État d'avancement du projet

### Fonctionnalités implémentées et planifiées

#### Gestion des joueurs

- [x] Création, modification et suppression de profils de joueurs
- [x] Sauvegarde des profils entre les sessions de jeu
- [x] Recherche des joueurs

#### Gestion des aliments

- [x] Ajout, modification et suppression d'aliments avec description
- [x] Attribution de points personnalisés pour chaque aliment (valeur par défaut: 1 point)

#### Système de jeu complet

- [x] Création de nouvelles parties avec sélection des joueurs participants
- [x] Interface de paris où chaque joueur sélectionne ses aliments
- [x] Écran de score final avec compilation des résultats
- [x] Option pour rejouer avec les mêmes joueurs

#### Historique et statistiques

- [x] Enregistrement automatique de l'historique des parties
- [x] Visualisation détaillée des statistiques par joueur
- [x] Comparaison des performances entre joueurs

#### Interface utilisateur

- [x] Design moderne et intuitif
- [x] Thème personnalisé avec couleurs harmonieuses
- [x] Expérience adaptée aux téléphones, tablettes et navigateurs web

#### Personnalisation avancée

- [ ] Importation/exportation des listes d'aliments
- [ ] Options de personnalisation visuelle (thèmes, couleurs)
- [ ] Ajout de photo de profil pour les joueurs
- [ ] Ajout d'image pour les aliments

#### Fonctionnalités sociales

- [ ] Partage des résultats sur les réseaux sociaux
- [ ] Classements et badges pour les accomplissements
- [ ] Option pour défier des amis à distance

#### Améliorations techniques

- [ ] Synchronisation cloud des données
- [ ] Support hors-ligne amélioré
- [ ] Optimisation des performances

#### Accessibilité

- [ ] Support complet des fonctionnalités d'accessibilité
- [ ] Mode daltonien
- [ ] Support des lecteurs d'écran
- [ ] Interface adaptable pour les personnes ayant des difficultés motrices

## Comment jouer

1. Commencez par créer une liste d'aliments dans la section "Gérer aliments"
2. Pour chaque aliment, vous pouvez définir une description et sa valeur en points (par défaut: 1 point)
3. Ajoutez des joueurs dans la section "Joueurs"
4. Démarrez une nouvelle partie et sélectionnez les joueurs participants
5. Chaque joueur choisit à son tour un aliment sur lequel parier
6. À la fin, sélectionnez les aliments qui étaient réellement présents lors de l'arrivage
7. Les joueurs marquent des points pour chaque prédiction correcte selon la valeur en points de l'aliment

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

L'application est actuellement en version 0.4.0 (Mai 2025)

## Statistiques des joueurs
