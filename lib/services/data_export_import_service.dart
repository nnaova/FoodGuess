import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
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
  /// [exportType] peut être "share" pour partager le fichier ou "local" pour l'enregistrer localement
  Future<String?> exportAllData({String exportType = "share"}) async {
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

      // Sauvegarder dans un fichier
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_export_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (exportType == "share") {
        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportation des données Food Guess',
        );
      } else if (exportType == "local") {
        // Télécharger localement - ne rien faire de plus car le fichier est déjà enregistré
        debugPrint('Fichier sauvegardé localement à: ${file.path}');
      }

      return file.path;
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
  /// [exportType] peut être "share" pour partager le fichier ou "local" pour l'enregistrer localement
  Future<String?> exportBetItems({String exportType = "share"}) async {
    try {
      final betItems = await _betItemStorage.loadBetItems();

      final exportData = {
        'betItems': betItems.map((item) => item.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(exportData);

      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_aliments_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (exportType == "share") {
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportation des aliments Food Guess',
        );
      } else if (exportType == "local") {
        // Télécharger localement - ne rien faire de plus car le fichier est déjà enregistré
        debugPrint('Fichier sauvegardé localement à: ${file.path}');
      }

      return file.path;
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
  /// [exportType] peut être "share" pour partager le fichier ou "local" pour l'enregistrer localement
  Future<String?> exportPlayers({String exportType = "share"}) async {
    try {
      final players = await _playerStorage.loadPlayers();

      final exportData = {
        'players': players.map((player) => player.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(exportData);

      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_joueurs_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (exportType == "share") {
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportation des joueurs Food Guess',
        );
      } else if (exportType == "local") {
        // Télécharger localement - ne rien faire de plus car le fichier est déjà enregistré
        debugPrint('Fichier sauvegardé localement à: ${file.path}');
      }

      return file.path;
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
  /// [exportType] peut être "share" pour partager le fichier ou "local" pour l'enregistrer localement
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

      // Sauvegarder dans un fichier
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_aliments_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      if (exportType == "share") {
        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportation des aliments Food Guess (CSV)',
        );
      } else if (exportType == "local") {
        // Télécharger localement - ne rien faire de plus car le fichier est déjà enregistré
        debugPrint('Fichier sauvegardé localement à: ${file.path}');
      }

      return file.path;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des aliments en CSV: $e');
      return null;
    }
  }

  /// Exporte les joueurs vers un fichier CSV
  ///
  /// [exportType] peut être "share" pour partager le fichier ou "local" pour l'enregistrer localement
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

      // Sauvegarder dans un fichier
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_joueurs_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      if (exportType == "share") {
        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportation des joueurs Food Guess (CSV)',
        );
      } else if (exportType == "local") {
        // Télécharger localement - ne rien faire de plus car le fichier est déjà enregistré
        debugPrint('Fichier sauvegardé localement à: ${file.path}');
      }

      return file.path;
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

  /// Prévisualiser les aliments avant de les importer (JSON)
  Future<List<BetItem>?> previewBetItemsImport() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return null;
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importData = jsonDecode(jsonString);

      if (!importData.containsKey('betItems')) {
        return null;
      }

      return (importData['betItems'] as List)
          .map((json) => BetItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la prévisualisation des aliments: $e');
      return null;
    }
  }

  /// Prévisualiser les joueurs avant de les importer (JSON)
  Future<List<Player>?> previewPlayersImport() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return null;
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importData = jsonDecode(jsonString);

      if (!importData.containsKey('players')) {
        return null;
      }

      return (importData['players'] as List)
          .map((json) => Player.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la prévisualisation des joueurs: $e');
      return null;
    }
  }

  /// Prévisualiser les aliments avant de les importer (CSV)
  Future<List<BetItem>?> previewBetItemsImportFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return null;
      }

      final file = File(filePath);
      final csvString = await file.readAsString();

      // Convertir le CSV en liste de lignes
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows.length < 2) {
        // Fichier vide ou sans données
        return null;
      }

      // Vérifier l'en-tête
      List<dynamic> headers = rows[0];
      if (headers.length < 3 ||
          !headers.contains('Nom') && !headers.contains('Name')) {
        // En-tête invalide
        return null;
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

      return newItems;
    } catch (e) {
      debugPrint(
          'Erreur lors de la prévisualisation des aliments depuis CSV: $e');
      return null;
    }
  }

  /// Exporte les aliments vers un fichier texte simple
  Future<String?> exportBetItemsAsText({String exportType = "share"}) async {
    try {
      final betItems = await _betItemStorage.loadBetItems();

      // Préparer les données pour le format texte
      StringBuffer buffer = StringBuffer();
      buffer.writeln("LISTE DES ALIMENTS FOOD GUESS");
      buffer.writeln("Exporté le ${DateTime.now().toString().split('.')[0]}");
      buffer.writeln("-----------------------------------");
      buffer.writeln();

      // Formatage des aliments
      for (int i = 0; i < betItems.length; i++) {
        var item = betItems[i];
        buffer.writeln("${i + 1}. ${item.name} (${item.points} points)");
        if (item.description.isNotEmpty) {
          buffer.writeln("   Description: ${item.description}");
        }
        buffer.writeln();
      }

      // Sauvegarder dans un fichier
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_aliments_$timestamp.txt';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(buffer.toString());

      if (exportType == "share") {
        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportation des aliments Food Guess (Texte)',
        );
      } else if (exportType == "local") {
        // Télécharger localement - ne rien faire de plus car le fichier est déjà enregistré
        debugPrint('Fichier sauvegardé localement à: ${file.path}');
      }

      return file.path;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des aliments en texte: $e');
      return null;
    }
  }

  /// Exporte les joueurs vers un fichier texte simple
  ///
  /// [exportType] peut être "share" pour partager le fichier ou "local" pour l'enregistrer localement
  Future<String?> exportPlayersAsText({String exportType = "share"}) async {
    try {
      final players = await _playerStorage.loadPlayers();

      // Préparer les données pour le format texte
      StringBuffer buffer = StringBuffer();
      buffer.writeln("LISTE DES JOUEURS FOOD GUESS");
      buffer.writeln("Exporté le ${DateTime.now().toString().split('.')[0]}");
      buffer.writeln("-----------------------------------");
      buffer.writeln();

      // Formatage des joueurs
      for (int i = 0; i < players.length; i++) {
        var player = players[i];
        buffer.writeln("${i + 1}. ${player.name}");
        buffer.writeln("   Score: ${player.score}");
        buffer.writeln();
      }

      // Sauvegarder dans un fichier
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_guess_joueurs_$timestamp.txt';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(buffer.toString());

      if (exportType == "share") {
        // Partager le fichier
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportation des joueurs Food Guess (Texte)',
        );
      } else if (exportType == "local") {
        // Télécharger localement - ne rien faire de plus car le fichier est déjà enregistré
        debugPrint('Fichier sauvegardé localement à: ${file.path}');
      }

      return file.path;
    } catch (e) {
      debugPrint('Erreur lors de l\'exportation des joueurs en texte: $e');
      return null;
    }
  }

  /// Valide la structure des données importées
  bool _validateImportData(Map<String, dynamic> data) {
    return data.containsKey('betItems') &&
        data.containsKey('players') &&
        data.containsKey('gameHistory');
  }
}
