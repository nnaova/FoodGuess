import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../models/bet_item.dart';
import '../models/player.dart';
import '../models/game_history_entry.dart';
import 'bet_item_storage.dart';
import 'player_storage.dart';
import 'game_history_storage.dart';

/// Service permettant d'exporter et d'importer les données de l'application
class DataExportImportService {
  final BetItemStorage _betItemStorage = BetItemStorage();
  final PlayerStorage _playerStorage = PlayerStorage();
  final GameHistoryStorage _gameHistoryStorage = GameHistoryStorage();

  /// Exporte toutes les données de l'application vers un fichier JSON
  ///
  /// [exportType] peut être "share" pour partager le fichier ou "custom" pour permettre
  /// à l'utilisateur de choisir l'emplacement de sauvegarde
  Future<String?> exportAllData({String exportType = "custom"}) async {
    try {
      // Récupérer les données
      final betItems = await _betItemStorage.loadBetItems();
      final players = await _playerStorage.loadPlayers();
      final gameHistory = await _gameHistoryStorage.loadGameHistory();

      // Créer l'objet de données à exporter
      final exportData = {
        'betItems': betItems.map((item) => item.toJson()).toList(),
        'players': players.map((player) => player.toJson()).toList(),
        'gameHistory': gameHistory.map((entry) => entry.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0', // À remplacer par la version réelle de l'app
      };

      // Convertir en JSON
      final jsonString = jsonEncode(exportData);

      String? filePath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_export_$timestamp.json';

      if (exportType == "share") {
        // Créer un fichier temporaire pour le partage
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        filePath = file.path;

        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exportation des données Food Guess',
        );
      } else if (exportType == "custom") {
        // Permettre à l'utilisateur de choisir l'emplacement
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Enregistrer le fichier d\'exportation',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
          // Essayer d'ouvrir le dossier de téléchargements par défaut si possible
          initialDirectory: await _getDownloadsDirectory(),
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonString);
          filePath = file.path;
          debugPrint('Fichier sauvegardé à l\'emplacement choisi: $filePath');
        } else {
          debugPrint('Exportation annulée par l\'utilisateur');
          return null;
        }
      }

      return filePath;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des données: $e');
      return null;
    }
  }

  /// Importe les données depuis un fichier JSON
  Future<bool> importAllData() async {
    try {
      // Sélectionner un fichier
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      // Récupérer le chemin du fichier sélectionné
      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      // Lire le contenu du fichier
      final file = File(filePath);
      final jsonString = await file.readAsString();

      // Décoder le JSON
      final Map<String, dynamic> importData = jsonDecode(jsonString);

      // Vérifier la structure des données
      if (!_validateImportData(importData)) {
        return false;
      }

      // Convertir les objets JSON en objets Dart
      final betItems = (importData['betItems'] as List)
          .map((json) => BetItem.fromJson(json))
          .toList();

      final players = (importData['players'] as List)
          .map((json) => Player.fromJson(json))
          .toList();

      final gameHistory = (importData['gameHistory'] as List)
          .map((json) => GameHistoryEntry.fromJson(json))
          .toList();

      // Sauvegarder les données importées
      await _betItemStorage.saveBetItems(betItems);
      await _playerStorage.savePlayers(players);

      // Pour l'historique, nous devons le traiter différemment car nous avons besoin
      // de préserver l'ordre des entrées
      await _gameHistoryStorage.clearHistory();
      for (var entry in gameHistory) {
        await _gameHistoryStorage.saveImportedHistoryEntry(entry);
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation des données: $e');
      return false;
    }
  }

  /// Exporte uniquement les aliments vers un fichier JSON
  ///
  /// [exportType] peut être "share" pour partager le fichier, "local" pour l'enregistrer localement
  /// ou "custom" pour permettre à l'utilisateur de choisir l'emplacement
  Future<String?> exportBetItems({String exportType = "share"}) async {
    try {
      final betItems = await _betItemStorage.loadBetItems();

      final exportData = {
        'betItems': betItems.map((item) => item.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(exportData);

      String? filePath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_aliments_$timestamp.json';

      if (exportType == "share") {
        // Créer un fichier temporaire pour le partage
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        filePath = file.path;

        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exportation des aliments Food Guess',
        );
      } else if (exportType == "local") {
        // Enregistrement avec emplacement par défaut
        final directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        filePath = file.path;

        debugPrint('Fichier sauvegardé localement à: $filePath');
      } else if (exportType == "custom") {
        // Permettre à l'utilisateur de choisir l'emplacement
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Enregistrer les aliments',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonString);
          filePath = file.path;
          debugPrint('Fichier sauvegardé à l\'emplacement choisi: $filePath');
        } else {
          debugPrint('Exportation annulée par l\'utilisateur');
          return null;
        }
      }

      return filePath;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des aliments: $e');
      return null;
    }
  }

  /// Importe uniquement les aliments depuis un fichier JSON
  Future<bool> importBetItems() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importData = jsonDecode(jsonString);

      if (!importData.containsKey('betItems')) {
        return false;
      }

      final betItems = (importData['betItems'] as List)
          .map((json) => BetItem.fromJson(json))
          .toList();

      // Option de fusion avec les données existantes
      final existingItems = await _betItemStorage.loadBetItems();

      // Trouver des éléments avec le même nom
      final existingNames =
          existingItems.map((item) => item.name.toLowerCase()).toSet();
      final newItems = betItems
          .where((item) => !existingNames.contains(item.name.toLowerCase()))
          .toList();

      // Ajouter uniquement les nouveaux éléments
      existingItems.addAll(newItems);
      await _betItemStorage.saveBetItems(existingItems);

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation des aliments: $e');
      return false;
    }
  }

  /// Exporte uniquement les joueurs vers un fichier JSON
  ///
  /// [exportType] peut être "share" pour partager le fichier, "local" pour l'enregistrer localement
  /// ou "custom" pour permettre à l'utilisateur de choisir l'emplacement
  Future<String?> exportPlayers({String exportType = "share"}) async {
    try {
      final players = await _playerStorage.loadPlayers();

      final exportData = {
        'players': players.map((player) => player.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(exportData);

      String? filePath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_joueurs_$timestamp.json';

      if (exportType == "share") {
        // Créer un fichier temporaire pour le partage
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        filePath = file.path;

        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exportation des joueurs Food Guess',
        );
      } else if (exportType == "local") {
        // Enregistrement avec emplacement par défaut
        final directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        filePath = file.path;

        debugPrint('Fichier sauvegardé localement à: $filePath');
      } else if (exportType == "custom") {
        // Permettre à l'utilisateur de choisir l'emplacement
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Enregistrer les joueurs',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonString);
          filePath = file.path;
          debugPrint('Fichier sauvegardé à l\'emplacement choisi: $filePath');
        } else {
          debugPrint('Exportation annulée par l\'utilisateur');
          return null;
        }
      }

      return filePath;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des joueurs: $e');
      return null;
    }
  }

  /// Importe uniquement les joueurs depuis un fichier JSON
  Future<bool> importPlayers() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importData = jsonDecode(jsonString);

      if (!importData.containsKey('players')) {
        return false;
      }

      final players = (importData['players'] as List)
          .map((json) => Player.fromJson(json))
          .toList();

      // Option de fusion avec les données existantes
      final existingPlayers = await _playerStorage.loadPlayers();

      // Trouver des joueurs avec le même nom
      final existingNames =
          existingPlayers.map((player) => player.name.toLowerCase()).toSet();
      final newPlayers = players
          .where((player) => !existingNames.contains(player.name.toLowerCase()))
          .toList();

      // Ajouter uniquement les nouveaux joueurs
      existingPlayers.addAll(newPlayers);
      await _playerStorage.savePlayers(existingPlayers);

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation des joueurs: $e');
      return false;
    }
  }

  /// Exporte les aliments vers un fichier CSV
  ///
  /// [exportType] peut être "share" pour partager le fichier, "local" pour l'enregistrer localement
  /// ou "custom" pour permettre à l'utilisateur de choisir l'emplacement
  Future<String?> exportBetItemsAsCSV({String exportType = "share"}) async {
    try {
      final betItems = await _betItemStorage.loadBetItems();

      // Préparer les données pour le CSV
      List<List<dynamic>> rows = [];

      // En-tête
      rows.add(['ID', 'Nom', 'Description', 'Points']);

      // Données
      for (var item in betItems) {
        rows.add([item.id, item.name, item.description, item.points]);
      }

      // Convertir en CSV
      String csv = const ListToCsvConverter().convert(rows);

      String? filePath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_aliments_$timestamp.csv';

      if (exportType == "share") {
        // Créer un fichier temporaire pour le partage
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csv);
        filePath = file.path;

        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exportation des aliments Food Guess (CSV)',
        );
      } else if (exportType == "local") {
        // Enregistrement avec emplacement par défaut
        final directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csv);
        filePath = file.path;

        debugPrint('Fichier sauvegardé localement à: $filePath');
      } else if (exportType == "custom") {
        // Permettre à l'utilisateur de choisir l'emplacement
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Enregistrer les aliments (CSV)',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(csv);
          filePath = file.path;
          debugPrint(
              'Fichier CSV sauvegardé à l\'emplacement choisi: $filePath');
        } else {
          debugPrint('Exportation CSV annulée par l\'utilisateur');
          return null;
        }
      }

      return filePath;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des aliments en CSV: $e');
      return null;
    }
  }

  /// Exporte les joueurs vers un fichier CSV
  ///
  /// [exportType] peut être "share" pour partager le fichier, "local" pour l'enregistrer localement
  /// ou "custom" pour permettre à l'utilisateur de choisir l'emplacement
  Future<String?> exportPlayersAsCSV({String exportType = "share"}) async {
    try {
      final players = await _playerStorage.loadPlayers();

      // Préparer les données pour le CSV
      List<List<dynamic>> rows = [];

      // En-tête
      rows.add(['ID', 'Nom', 'Score']);

      // Données
      for (var player in players) {
        rows.add([player.id, player.name, player.score]);
      }

      // Convertir en CSV
      String csv = const ListToCsvConverter().convert(rows);

      String? filePath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_joueurs_$timestamp.csv';

      if (exportType == "share") {
        // Créer un fichier temporaire pour le partage
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csv);
        filePath = file.path;

        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Exportation des joueurs Food Guess (CSV)',
        );
      } else if (exportType == "local") {
        // Enregistrement avec emplacement par défaut
        final directory = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csv);
        filePath = file.path;

        debugPrint('Fichier sauvegardé localement à: $filePath');
      } else if (exportType == "custom") {
        // Permettre à l'utilisateur de choisir l'emplacement
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Enregistrer les joueurs (CSV)',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(csv);
          filePath = file.path;
          debugPrint(
              'Fichier CSV sauvegardé à l\'emplacement choisi: $filePath');
        } else {
          debugPrint('Exportation CSV annulée par l\'utilisateur');
          return null;
        }
      }

      return filePath;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des joueurs en CSV: $e');
      return null;
    }
  }

  /// Importe les aliments depuis un fichier CSV
  Future<bool> importBetItemsFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      final file = File(filePath);
      final csvString = await file.readAsString();

      // Convertir le CSV en liste de lignes
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows.length < 2) {
        // Fichier vide ou sans données
        return false;
      }

      // Vérifier l'en-tête
      List<dynamic> headers = rows[0];
      if (headers.length < 3 ||
          !headers.contains('Nom') && !headers.contains('Name')) {
        // En-tête invalide
        return false;
      }

      // Récupérer les index des colonnes
      int nameIndex = headers.indexOf('Nom');
      if (nameIndex == -1) nameIndex = headers.indexOf('Name');

      int descIndex = headers.indexOf('Description');
      if (descIndex == -1) descIndex = headers.indexOf('Description');

      int pointsIndex = headers.indexOf('Points');
      if (pointsIndex == -1) pointsIndex = headers.indexOf('Points');

      // Convertir les lignes en objets BetItem
      List<BetItem> newItems = [];
      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length <= nameIndex) continue;

        String name = rows[i][nameIndex].toString();
        if (name.isEmpty) continue;

        String description = '';
        if (descIndex != -1 && rows[i].length > descIndex) {
          description = rows[i][descIndex].toString();
        }

        int points = 1;
        if (pointsIndex != -1 && rows[i].length > pointsIndex) {
          try {
            points = int.parse(rows[i][pointsIndex].toString());
          } catch (e) {
            // Ignorer les erreurs de conversion
          }
        }

        newItems.add(BetItem(
          id: const Uuid().v4(),
          name: name,
          description: description,
          points: points,
        ));
      }

      if (newItems.isEmpty) {
        return false;
      }

      // Option de fusion avec les données existantes
      final existingItems = await _betItemStorage.loadBetItems();

      // Trouver des éléments avec le même nom
      final existingNames =
          existingItems.map((item) => item.name.toLowerCase()).toSet();
      final uniqueNewItems = newItems
          .where((item) => !existingNames.contains(item.name.toLowerCase()))
          .toList();

      // Ajouter uniquement les nouveaux éléments
      existingItems.addAll(uniqueNewItems);
      await _betItemStorage.saveBetItems(existingItems);

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation des aliments depuis CSV: $e');
      return false;
    }
  }

  /// Importe les joueurs depuis un fichier CSV
  Future<bool> importPlayersFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      final file = File(filePath);
      final csvString = await file.readAsString();

      // Convertir le CSV en liste de lignes
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows.length < 2) {
        // Fichier vide ou sans données
        return false;
      }

      // Vérifier l'en-tête
      List<dynamic> headers = rows[0];
      if (headers.length < 2 || !headers.contains('Nom')) {
        // En-tête invalide
        return false;
      }

      // Récupérer les index des colonnes
      int nameIndex = headers.indexOf('Nom');

      int scoreIndex = headers.indexOf('Score');
      if (scoreIndex == -1) scoreIndex = headers.indexOf('Score');

      // Convertir les lignes en objets Player
      List<Player> newPlayers = [];
      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length <= nameIndex) continue;

        String name = rows[i][nameIndex].toString();
        if (name.isEmpty) continue;

        int score = 0;
        if (scoreIndex != -1 && rows[i].length > scoreIndex) {
          try {
            score = int.parse(rows[i][scoreIndex].toString());
          } catch (e) {
            // Ignorer les erreurs de conversion
          }
        }

        newPlayers.add(Player(
          id: const Uuid().v4(),
          name: name,
          score: score,
        ));
      }

      if (newPlayers.isEmpty) {
        return false;
      }

      // Option de fusion avec les données existantes
      final existingPlayers = await _playerStorage.loadPlayers();

      // Trouver des joueurs avec le même nom
      final existingNames =
          existingPlayers.map((player) => player.name.toLowerCase()).toSet();
      final uniqueNewPlayers = newPlayers
          .where((player) => !existingNames.contains(player.name.toLowerCase()))
          .toList();

      // Ajouter uniquement les nouveaux joueurs
      existingPlayers.addAll(uniqueNewPlayers);
      await _playerStorage.savePlayers(existingPlayers);

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation des joueurs depuis CSV: $e');
      return false;
    }
  }

  /// Valide la structure des données importées
  bool _validateImportData(Map<String, dynamic> data) {
    return data.containsKey('betItems') &&
        data.containsKey('players') &&
        data.containsKey('gameHistory');
  }

  Future<String?> _getDownloadsDirectory() async {
    String? downloadsPath;

    try {
      // Essayer d'obtenir le chemin des téléchargements à partir du répertoire externe
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        downloadsPath = '${externalDir.path}/Download';
      }
    } catch (e) {
      debugPrint(
          'Erreur lors de la récupération du répertoire de téléchargements: $e');
    }

    return downloadsPath;
  }

  previewBetItemsImport() {}

  previewBetItemsImportFromCSV() {}

  previewPlayersImport() {}

  exportPlayersAsText({required String exportType}) {}

  exportBetItemsAsText({required String exportType}) {}

  /// Importe des aliments depuis l'API externe
  Future<bool> importBetItemsFromApi() async {
    try {
      debugPrint(
          'Début de l\'importation des aliments depuis l\'API externe...');

      final List<BetItem>? apiItems = await _fetchBetItemsFromApi();

      if (apiItems == null) {
        debugPrint(
            'Échec de la récupération des données depuis l\'API externe');
        return false;
      }

      if (apiItems.isEmpty) {
        debugPrint('L\'API externe n\'a retourné aucun élément');
        return false;
      }

      debugPrint('${apiItems.length} éléments récupérés depuis l\'API externe');

      // Fusionner avec les données existantes
      final existingItems = await _betItemStorage.loadBetItems();
      debugPrint(
          '${existingItems.length} éléments existants dans la base locale');

      // Trouver des éléments avec le même nom
      final existingNames =
          existingItems.map((item) => item.name.toLowerCase()).toSet();
      final newItems = apiItems
          .where((item) => !existingNames.contains(item.name.toLowerCase()))
          .toList();

      if (newItems.isEmpty) {
        debugPrint(
            'Aucun nouvel aliment à importer depuis l\'API externe (tous déjà présents)');
        return false;
      }

      // Ajouter uniquement les nouveaux éléments
      existingItems.addAll(newItems);
      await _betItemStorage.saveBetItems(existingItems);

      debugPrint(
          'Succès: ${newItems.length} aliments importés depuis l\'API externe');
      return true;
    } catch (e) {
      debugPrint(
          'Erreur lors de l\'importation des aliments depuis l\'API externe: $e');
      return false;
    }
  }

  /// Prévisualise les aliments disponibles depuis l'API externe
  Future<List<BetItem>?> previewBetItemsFromApi() async {
    try {
      final List<BetItem>? apiItems = await _fetchBetItemsFromApi();

      if (apiItems == null || apiItems.isEmpty) {
        debugPrint('Aucun élément retourné par l\'API');
        return null;
      }

      // Marquer les éléments déjà existants
      final existingItems = await _betItemStorage.loadBetItems();
      final existingNames =
          existingItems.map((item) => item.name.toLowerCase()).toSet();

      // Créer une nouvelle liste pour éviter de modifier les objets originaux de la map
      List<BetItem> previewItems = [];

      for (var item in apiItems) {
        if (existingNames.contains(item.name.toLowerCase())) {
          // Créer une nouvelle instance avec la description mise à jour
          previewItems.add(item.copyWith(
              description: item.description.isEmpty
                  ? '[Déjà présent dans votre liste]'
                  : '${item.description} [Déjà présent dans votre liste]'));
        } else {
          previewItems.add(item);
        }
      }

      debugPrint(
          'Prévisualisation: ${previewItems.length} aliments disponibles');
      return previewItems;
    } catch (e) {
      debugPrint(
          'Erreur lors de la prévisualisation des aliments depuis l\'API: $e');
      return null;
    }
  }

  /// Récupère les aliments depuis l'API externe
  Future<List<BetItem>?> _fetchBetItemsFromApi() async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('https://food-guess-api.vercel.app/api/foods'),
      );

      if (response.statusCode != 200) {
        debugPrint('Erreur API: ${response.statusCode} ${response.body}');
        return null;
      }

      // Analyser la réponse JSON qui contient un objet avec un tableau "betItems"
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> betItems = jsonResponse['betItems'] ?? [];

      final List<BetItem> apiItems = betItems.map((item) {
        // Vérifier si l'élément possède un champ isScoring
        bool isScoring = false;
        if (item.containsKey('isScoring')) {
          isScoring = item['isScoring'] == true;
        }

        // Gérer le champ points (qui peut être un nombre ou une chaîne)
        int points = 1;
        if (item.containsKey('points')) {
          if (item['points'] is int) {
            points = item['points'];
          } else if (item['points'] is String) {
            points = int.tryParse(item['points']) ?? 1;
          }
        }

        return BetItem(
          id: item['id'] ?? const Uuid().v4(),
          name: item['name'] ?? 'Inconnu',
          description: item['description'] ?? '',
          isScoring: isScoring,
          points: points,
        );
      }).toList();

      debugPrint('API: ${apiItems.length} aliments récupérés');
      return apiItems;
    } catch (e) {
      if (e is FormatException) {
        debugPrint(
            'Erreur de format JSON lors de la récupération des aliments depuis l\'API: $e');
      } else if (e is http.ClientException) {
        debugPrint(
            'Erreur de connexion lors de la récupération des aliments depuis l\'API: $e');
      } else {
        debugPrint(
            'Erreur lors de la récupération des aliments depuis l\'API: $e');
      }
      return null;
    }
  }
}
