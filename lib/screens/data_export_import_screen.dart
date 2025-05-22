// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import '../services/data_export_import_service.dart';
import '../models/bet_item.dart';
import '../models/player.dart';
import 'dart:io';

class DataExportImportScreen extends StatefulWidget {
  const DataExportImportScreen({super.key});

  @override
  State<DataExportImportScreen> createState() => _DataExportImportScreenState();
}

class _DataExportImportScreenState extends State<DataExportImportScreen> {
  final DataExportImportService _service = DataExportImportService();
  bool _isExporting = false;
  bool _isImporting = false;
  String? _lastActionResult;
  bool _isSuccess = false;

  Future<void> _exportAllData({String exportType = "share"}) async {
    setState(() {
      _isExporting = true;
      _lastActionResult = null;
    });

    try {
      final filePath = await _service.exportAllData(exportType: exportType);

      setState(() {
        _isExporting = false;
        if (filePath != null) {
          if (exportType == "local") {
            _lastActionResult =
                'Les données ont été sauvegardées localement:\n$filePath';
            _showLocalStorageNotification(filePath);
          } else {
            _lastActionResult = 'Les données ont été exportées avec succès.';
          }
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'exportation a échoué.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _lastActionResult = 'Erreur lors de l\'exportation: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _importAllData() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final success = await _service.importAllData();

      setState(() {
        _isImporting = false;
        if (success) {
          _lastActionResult = 'Les données ont été importées avec succès.';
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'importation a échoué ou a été annulée.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de l\'importation: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _exportBetItems({String exportType = "share"}) async {
    setState(() {
      _isExporting = true;
      _lastActionResult = null;
    });

    try {
      final filePath = await _service.exportBetItems(exportType: exportType);

      setState(() {
        _isExporting = false;
        if (filePath != null) {
          if (exportType == "local") {
            _lastActionResult =
                'Les aliments ont été sauvegardés localement:\n$filePath';
            _showLocalStorageNotification(filePath);
          } else {
            _lastActionResult = 'Les aliments ont été exportés avec succès.';
          }
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'exportation des aliments a échoué.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _lastActionResult = 'Erreur lors de l\'exportation des aliments: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _importBetItems() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final success = await _service.importBetItems();

      setState(() {
        _isImporting = false;
        if (success) {
          _lastActionResult = 'Les aliments ont été importés avec succès.';
          _isSuccess = true;
        } else {
          _lastActionResult =
              'L\'importation des aliments a échoué ou a été annulée.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de l\'importation des aliments: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _exportPlayers({String exportType = "share"}) async {
    setState(() {
      _isExporting = true;
      _lastActionResult = null;
    });

    try {
      final filePath = await _service.exportPlayers(exportType: exportType);

      setState(() {
        _isExporting = false;
        if (filePath != null) {
          if (exportType == "local") {
            _lastActionResult =
                'Les joueurs ont été sauvegardés localement:\n$filePath';
            _showLocalStorageNotification(filePath);
          } else {
            _lastActionResult = 'Les joueurs ont été exportés avec succès.';
          }
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'exportation des joueurs a échoué.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _lastActionResult = 'Erreur lors de l\'exportation des joueurs: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _importPlayers() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final success = await _service.importPlayers();

      setState(() {
        _isImporting = false;
        if (success) {
          _lastActionResult = 'Les joueurs ont été importés avec succès.';
          _isSuccess = true;
        } else {
          _lastActionResult =
              'L\'importation des joueurs a échoué ou a été annulée.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de l\'importation des joueurs: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _exportBetItemsAsCSV({String exportType = "share"}) async {
    setState(() {
      _isExporting = true;
      _lastActionResult = null;
    });

    try {
      final filePath =
          await _service.exportBetItemsAsCSV(exportType: exportType);

      setState(() {
        _isExporting = false;
        if (filePath != null) {
          if (exportType == "local") {
            _lastActionResult =
                'Les aliments ont été sauvegardés en CSV localement:\n$filePath';
            _showLocalStorageNotification(filePath);
          } else {
            _lastActionResult =
                'Les aliments ont été exportés en format CSV avec succès.';
          }
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'exportation des aliments en CSV a échoué.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _lastActionResult =
            'Erreur lors de l\'exportation des aliments en CSV: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _exportPlayersAsCSV({String exportType = "share"}) async {
    setState(() {
      _isExporting = true;
      _lastActionResult = null;
    });

    try {
      final filePath =
          await _service.exportPlayersAsCSV(exportType: exportType);

      setState(() {
        _isExporting = false;
        if (filePath != null) {
          if (exportType == "local") {
            _lastActionResult =
                'Les joueurs ont été sauvegardés en CSV localement:\n$filePath';
            _showLocalStorageNotification(filePath);
          } else {
            _lastActionResult =
                'Les joueurs ont été exportés en format CSV avec succès.';
          }
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'exportation des joueurs en CSV a échoué.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _lastActionResult =
            'Erreur lors de l\'exportation des joueurs en CSV: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _importBetItemsFromCSV() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final success = await _service.importBetItemsFromCSV();

      setState(() {
        _isImporting = false;
        if (success) {
          _lastActionResult =
              'Les aliments ont été importés depuis le CSV avec succès.';
          _isSuccess = true;
        } else {
          _lastActionResult =
              'L\'importation des aliments depuis le CSV a échoué ou a été annulée.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult =
            'Erreur lors de l\'importation des aliments depuis CSV: $e';
        _isSuccess = false;
      });
    }
  }

  // Prévisualiser les aliments avant import
  Future<void> _previewBetItems() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final items = await _service.previewBetItemsImport();

      setState(() {
        _isImporting = false;
      });

      if (items != null && items.isNotEmpty) {
        _showPreviewDialog('Aliments à importer', _buildBetItemsPreview(items),
            () {
          _importBetItems();
        });
      } else {
        setState(() {
          _lastActionResult =
              'Aucun aliment valide à prévisualiser ou fichier invalide.';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de la prévisualisation: $e';
        _isSuccess = false;
      });
    }
  }

  // Prévisualiser les aliments CSV avant import
  Future<void> _previewBetItemsCSV() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final items = await _service.previewBetItemsImportFromCSV();

      setState(() {
        _isImporting = false;
      });

      if (items != null && items.isNotEmpty) {
        _showPreviewDialog(
            'Aliments à importer (CSV)', _buildBetItemsPreview(items), () {
          _importBetItemsFromCSV();
        });
      } else {
        setState(() {
          _lastActionResult =
              'Aucun aliment valide à prévisualiser ou fichier CSV invalide.';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de la prévisualisation CSV: $e';
        _isSuccess = false;
      });
    }
  }

  // Prévisualiser les joueurs avant import
  Future<void> _previewPlayers() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final players = await _service.previewPlayersImport();

      setState(() {
        _isImporting = false;
      });

      if (players != null && players.isNotEmpty) {
        _showPreviewDialog('Joueurs à importer', _buildPlayersPreview(players),
            () {
          _importPlayers();
        });
      } else {
        setState(() {
          _lastActionResult =
              'Aucun joueur valide à prévisualiser ou fichier invalide.';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de la prévisualisation: $e';
        _isSuccess = false;
      });
    }
  }

  // Afficher le dialogue de prévisualisation
  void _showPreviewDialog(
      String title, Widget content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

  // Construire la prévisualisation des aliments
  Widget _buildBetItemsPreview(List<BetItem> items) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.description.isNotEmpty
                ? item.description
                : 'Pas de description'),
            trailing: Text('${item.points} pt${item.points > 1 ? 's' : ''}'),
          );
        },
      ),
    );
  }

  // Construire la prévisualisation des joueurs
  Widget _buildPlayersPreview(List<Player> players) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return ListTile(
            title: Text(player.name),
            trailing: Text('Score: ${player.score}'),
          );
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide sur l\'importation et l\'exportation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Formats supportés:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• JSON: Format complet qui préserve toutes les données\n'
                '• CSV: Format simplifié compatible avec les tableurs (Excel, Google Sheets, etc.)\n'
                '• API: Importation directe depuis notre service en ligne',
              ),
              SizedBox(height: 16),
              Text(
                'Exportation:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'L\'exportation crée un fichier sur votre appareil et vous propose de le partager. '
                'Vous pouvez l\'envoyer par email, le sauvegarder dans le cloud, etc.\n\n'
                'L\'option "Sauvegarder localement" stocke le fichier directement sur votre appareil.',
              ),
              SizedBox(height: 16),
              Text(
                'Importation:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Lors de l\'importation, les éléments ayant des noms identiques ne seront pas dupliqués. '
                'Assurez-vous que le fichier que vous importez provient d\'une source fiable.',
              ),
              SizedBox(height: 16),
              Text(
                'Importation via API:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'L\'importation via API vous permet de récupérer des aliments depuis notre service en ligne. '
                'Cette fonctionnalité nécessite une connexion Internet et sera pleinement opérationnelle prochainement.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLocalStorageNotification(String filePath) {
    // Vérifier si nous sommes dans un état monté
    if (!mounted) return;

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    showDialog(
      context: context,
      barrierDismissible:
          false, // L'utilisateur doit cliquer sur un bouton pour fermer
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_done_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Fichier sauvegardé',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? double.infinity : 450,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Le fichier a été sauvegardé avec succès sur votre appareil à l\'emplacement suivant:',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 15),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        // ignore: duplicate_ignore
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  child: SelectableText(
                    filePath,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vous pouvez accéder à ce fichier via votre gestionnaire de fichiers.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.folder_open),
            label: const Text('Ouvrir le dossier'),
            onPressed: () {
              // Extraire le dossier parent du chemin du fichier
              final directoryPath =
                  filePath.substring(0, filePath.lastIndexOf('/'));
              // Tenter d'ouvrir le dossier (cela ne fonctionne que sur certaines plateformes)
              try {
                Directory(directoryPath).create(recursive: true);
                // Sur Android, on pourrait utiliser des plugins comme open_file pour ouvrir le gestionnaire de fichiers
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Le dossier devrait s\'ouvrir si supporté par votre appareil'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                debugPrint('Impossible d\'ouvrir le dossier: $e');
              }
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Afficher également un snackbar pour notifier l'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        content: Row(
          children: [
            Icon(
              Icons.file_download_done,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Fichier sauvegardé localement',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Détecter la taille de l'écran pour la réactivité
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importation et Exportation'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Aide sur l\'importation et l\'exportation',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10.0 : 16.0,
              vertical: isSmallScreen ? 8.0 : 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section d'information
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          // ignore: deprecated_member_use
                          .withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 10 : 12),
                    onTap: _showHelpDialog,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                size: isSmallScreen ? 22 : 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Exportation et importation de données',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.touch_app,
                                size: isSmallScreen ? 16 : 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Exportez vos données pour les sauvegarder ou partagez-les. Importez des données depuis des fichiers partagés.',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.save_alt,
                                size: isSmallScreen ? 14 : 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Formats disponibles: JSON, CSV et Texte',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sections d'export/import
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toutes les données
                        _buildSectionCard(
                          'Toutes les données',
                          'Exporter ou importer tous les joueurs, aliments et l\'historique des parties.',
                          [
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'share') {
                                  _exportAllData(exportType: "share");
                                } else if (value == 'local') {
                                  _exportAllData(exportType: "local");
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Text('Exporter et partager'),
                                ),
                                const PopupMenuItem(
                                  value: 'local',
                                  child: Text('Sauvegarder localement'),
                                ),
                              ],
                              tooltip: 'Options d\'exportation',
                              child: _buildActionButton(
                                'Exporter',
                                Icons.upload_file,
                                null, // On utilise PopupMenuButton à la place
                                _isExporting,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              'Importer',
                              Icons.download_rounded,
                              _importAllData,
                              _isImporting,
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 8 : 12),

                        // Aliments seulement
                        _buildSectionCard(
                          'Aliments seulement',
                          'Exporter ou importer uniquement la liste des aliments disponibles.',
                          [
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'json_share') {
                                  _exportBetItems(exportType: "share");
                                } else if (value == 'json_local') {
                                  _exportBetItems(exportType: "local");
                                } else if (value == 'csv_share') {
                                  _exportBetItemsAsCSV(exportType: "share");
                                } else if (value == 'csv_local') {
                                  _exportBetItemsAsCSV(exportType: "local");
                                } else if (value == 'text_share') {
                                  _exportBetItemsAsText(exportType: "share");
                                } else if (value == 'text_local') {
                                  _exportBetItemsAsText(exportType: "local");
                                }
                              },
                              tooltip: 'Options d\'exportation',
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'json_share',
                                  child: Text('Exporter et partager (JSON)'),
                                ),
                                const PopupMenuItem(
                                  value: 'json_local',
                                  child: Text('Sauvegarder localement (JSON)'),
                                ),
                                const PopupMenuItem(
                                  value: 'csv_share',
                                  child: Text('Exporter et partager (CSV)'),
                                ),
                                const PopupMenuItem(
                                  value: 'csv_local',
                                  child: Text('Sauvegarder localement (CSV)'),
                                ),
                                const PopupMenuItem(
                                  value: 'text_share',
                                  child: Text('Exporter et partager (Texte)'),
                                ),
                                const PopupMenuItem(
                                  value: 'text_local',
                                  child: Text('Sauvegarder localement (Texte)'),
                                ),
                              ],
                              child: _buildActionButton(
                                'Exporter',
                                Icons.upload_file,
                                null, // On utilise PopupMenuButton à la place
                                _isExporting,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'json_preview') {
                                  _previewBetItems();
                                } else if (value == 'csv_preview') {
                                  _previewBetItemsCSV();
                                } else if (value == 'api_preview') {
                                  _previewBetItemsFromApi();
                                } else if (value == 'json_direct') {
                                  _importBetItems();
                                } else if (value == 'csv_direct') {
                                  _importBetItemsFromCSV();
                                } else if (value == 'api_direct') {
                                  _importBetItemsFromApi();
                                }
                              },
                              tooltip: 'Options d\'importation',
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'json_preview',
                                  child: Text(
                                      'Prévisualiser puis importer (JSON)'),
                                ),
                                const PopupMenuItem(
                                  value: 'csv_preview',
                                  child:
                                      Text('Prévisualiser puis importer (CSV)'),
                                ),
                                const PopupMenuItem(
                                  value: 'api_preview',
                                  child:
                                      Text('Prévisualiser puis importer (API)'),
                                ),
                                const PopupMenuItem(
                                  value: 'json_direct',
                                  child: Text('Importer directement (JSON)'),
                                ),
                                const PopupMenuItem(
                                  value: 'csv_direct',
                                  child: Text('Importer directement (CSV)'),
                                ),
                                const PopupMenuItem(
                                  value: 'api_direct',
                                  child: Text('Importer directement (API)'),
                                ),
                              ],
                              child: _buildActionButton(
                                'Importer',
                                Icons.download_rounded,
                                null, // On utilise PopupMenuButton à la place
                                _isImporting,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 8 : 12),

                        // Joueurs seulement
                        _buildSectionCard(
                          'Joueurs seulement',
                          'Exporter ou importer uniquement la liste des joueurs.',
                          [
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'json_share') {
                                  _exportPlayers(exportType: "share");
                                } else if (value == 'json_local') {
                                  _exportPlayers(exportType: "local");
                                } else if (value == 'csv_share') {
                                  _exportPlayersAsCSV(exportType: "share");
                                } else if (value == 'csv_local') {
                                  _exportPlayersAsCSV(exportType: "local");
                                } else if (value == 'text_share') {
                                  _exportPlayersAsText(exportType: "share");
                                } else if (value == 'text_local') {
                                  _exportPlayersAsText(exportType: "local");
                                }
                              },
                              tooltip: 'Options d\'exportation',
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'json_share',
                                  child: Text('Exporter et partager (JSON)'),
                                ),
                                const PopupMenuItem(
                                  value: 'json_local',
                                  child: Text('Sauvegarder localement (JSON)'),
                                ),
                                const PopupMenuItem(
                                  value: 'csv_share',
                                  child: Text('Exporter et partager (CSV)'),
                                ),
                                const PopupMenuItem(
                                  value: 'csv_local',
                                  child: Text('Sauvegarder localement (CSV)'),
                                ),
                                const PopupMenuItem(
                                  value: 'text_share',
                                  child: Text('Exporter et partager (Texte)'),
                                ),
                                const PopupMenuItem(
                                  value: 'text_local',
                                  child: Text('Sauvegarder localement (Texte)'),
                                ),
                              ],
                              child: _buildActionButton(
                                'Exporter',
                                Icons.upload_file,
                                null, // On utilise PopupMenuButton à la place
                                _isExporting,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'preview') {
                                  _previewPlayers();
                                } else if (value == 'direct') {
                                  _importPlayers();
                                }
                              },
                              tooltip: 'Options d\'importation',
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'preview',
                                  child: Text('Prévisualiser puis importer'),
                                ),
                                const PopupMenuItem(
                                  value: 'direct',
                                  child: Text('Importer directement'),
                                ),
                              ],
                              child: _buildActionButton(
                                'Importer',
                                Icons.download_rounded,
                                null, // On utilise PopupMenuButton à la place
                                _isImporting,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Message de résultat
              if (_lastActionResult != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  margin: EdgeInsets.only(
                      top: isSmallScreen ? 12 : 16,
                      bottom: isSmallScreen ? 4 : 8),
                  decoration: BoxDecoration(
                    color:
                        _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 10 : 12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: _isSuccess
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5)
                          : Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isSuccess
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isSuccess ? Icons.check_circle : Icons.error,
                              color: _isSuccess
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Expanded(
                            child: Text(
                              _isSuccess ? 'Succès' : 'Erreur',
                              style: TextStyle(
                                color: _isSuccess
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                size: isSmallScreen ? 18 : 20),
                            onPressed: () {
                              setState(() {
                                _lastActionResult = null;
                              });
                            },
                            color: _isSuccess
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Padding(
                        padding: EdgeInsets.only(left: isSmallScreen ? 32 : 40),
                        child: Text(
                          _lastActionResult!,
                          style: TextStyle(
                            color: _isSuccess
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                          maxLines: isSmallScreen ? 3 : null,
                          overflow: isSmallScreen
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      String title, String description, List<Widget> actions) {
    // Détecter la taille de l'écran pour la réactivité
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
      ),
      margin: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 4 : 8, horizontal: isSmallScreen ? 0 : 4),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.7),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _getSectionIcon(title),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: isSmallScreen ? 2 : 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            if (isSmallScreen || actions.length > 2)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Si l'espace est vraiment étroit, on empile verticalement
                  if (isVerySmallScreen) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: actions.map((widget) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: widget,
                        );
                      }).toList(),
                    );
                  } else {
                    // Sinon on essaie de distribuer les actions en grille (2 par ligne)
                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: actions.map((widget) {
                        return SizedBox(
                          width: constraints.maxWidth > 450
                              ? (constraints.maxWidth - 8) / 2
                              : constraints.maxWidth,
                          child: widget,
                        );
                      }).toList(),
                    );
                  }
                },
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
          ],
        ),
      ),
    );
  }

  // Fonction pour déterminer l'icône selon le titre de la section
  IconData _getSectionIcon(String title) {
    if (title.toLowerCase().contains('toutes')) {
      return Icons.storage;
    } else if (title.toLowerCase().contains('aliments')) {
      return Icons.fastfood;
    } else if (title.toLowerCase().contains('joueurs')) {
      return Icons.people;
    }
    return Icons.category;
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback? onPressed,
    bool isLoading,
  ) {
    // Détecter la taille de l'écran pour la réactivité
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    // Déterminer la couleur et le style selon le type de bouton
    Color buttonColor;
    Color textColor;
    Color iconColor;

    if (label.toLowerCase().contains('exporter')) {
      buttonColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
      iconColor = Theme.of(context).colorScheme.onPrimary;
    } else if (label.toLowerCase().contains('importer')) {
      buttonColor = Theme.of(context).colorScheme.secondary;
      textColor = Theme.of(context).colorScheme.onSecondary;
      iconColor = Theme.of(context).colorScheme.onSecondary;
    } else {
      buttonColor = Theme.of(context).colorScheme.surfaceVariant;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
      iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      width: isSmallScreen ? double.infinity : null,
      constraints: BoxConstraints(
        minWidth: isVerySmallScreen ? double.infinity : 110,
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    buttonColor.withOpacity(0.7),
                  ),
                ),
              )
            : Icon(
                icon,
                size: isSmallScreen ? 18 : 20,
                color: iconColor,
              ),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 13 : 14,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
          ),
          minimumSize: isSmallScreen
              ? const Size(0, 40) // Plus petit pour petits écrans
              : const Size(0, 44),
          elevation: 1,
        ),
      ),
    );
  }

  Future<void> _exportPlayersAsText({String exportType = "share"}) async {
    setState(() {
      _isExporting = true;
      _lastActionResult = null;
    });

    try {
      final filePath =
          await _service.exportPlayersAsText(exportType: exportType);

      setState(() {
        _isExporting = false;
        if (filePath != null) {
          if (exportType == "local") {
            _lastActionResult =
                'Les joueurs ont été sauvegardés en texte localement:\n$filePath';
            _showLocalStorageNotification(filePath);
          } else {
            _lastActionResult =
                'Les joueurs ont été exportés en format texte avec succès.';
          }
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'exportation des joueurs en texte a échoué.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _lastActionResult =
            'Erreur lors de l\'exportation des joueurs en texte: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _exportBetItemsAsText({String exportType = "share"}) async {
    setState(() {
      _isExporting = true;
      _lastActionResult = null;
    });

    try {
      final filePath =
          await _service.exportBetItemsAsText(exportType: exportType);

      setState(() {
        _isExporting = false;
        if (filePath != null) {
          if (exportType == "local") {
            _lastActionResult =
                'Les aliments ont été sauvegardés en texte localement:\n$filePath';
            _showLocalStorageNotification(filePath);
          } else {
            _lastActionResult =
                'Les aliments ont été exportés en format texte avec succès.';
          }
          _isSuccess = true;
        } else {
          _lastActionResult = 'L\'exportation des aliments en texte a échoué.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _lastActionResult =
            'Erreur lors de l\'exportation des aliments en texte: $e';
        _isSuccess = false;
      });
    }
  }

  // Importer des aliments depuis l'API
  Future<void> _importBetItemsFromApi() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final success = await _service.importBetItemsFromApi();

      setState(() {
        _isImporting = false;
        if (success) {
          _lastActionResult =
              'Les aliments ont été importés depuis l\'API avec succès.';
          _isSuccess = true;
        } else {
          _lastActionResult =
              'L\'importation des aliments depuis l\'API a échoué ou aucun nouvel aliment n\'a été trouvé.';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de l\'importation depuis l\'API: $e';
        _isSuccess = false;
      });
    }
  }

  // Prévisualiser les aliments depuis l'API avant import
  Future<void> _previewBetItemsFromApi() async {
    setState(() {
      _isImporting = true;
      _lastActionResult = null;
    });

    try {
      final items = await _service.previewBetItemsFromApi();

      setState(() {
        _isImporting = false;
      });

      if (items != null && items.isNotEmpty) {
        _showPreviewDialog(
          'Aliments disponibles via l\'API',
          _buildBetItemsPreviewFromApi(items),
          () {
            _importBetItemsFromApi();
          },
        );
      } else {
        setState(() {
          _lastActionResult =
              'Aucun aliment disponible via l\'API ou erreur de connexion.';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _lastActionResult = 'Erreur lors de la connexion à l\'API: $e';
        _isSuccess = false;
      });
    }
  }

  // Construire la prévisualisation des aliments de l'API
  Widget _buildBetItemsPreviewFromApi(List<BetItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            '${items.length} aliment${items.length > 1 ? "s" : ""} disponible${items.length > 1 ? "s" : ""} dans l\'API',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final bool isAlreadyExists =
                  item.description.contains('[Déjà présent dans votre liste]');

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: isAlreadyExists ? Colors.grey.shade100 : Colors.white,
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.description.isNotEmpty && !isAlreadyExists)
                        Text(item.description),
                      if (isAlreadyExists)
                        Text(
                          'Déjà présent dans votre liste',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.red.shade800,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.points} pt${item.points > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
