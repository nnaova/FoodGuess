import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/bet_item.dart';
import '../services/bet_item_storage.dart';

class BetItemsScreen extends StatefulWidget {
  const BetItemsScreen({super.key});

  @override
  State<BetItemsScreen> createState() => _BetItemsScreenState();
}

class _BetItemsScreenState extends State<BetItemsScreen> {
  // Liste des éléments pariables
  List<BetItem> _betItems = [];
  List<BetItem> _filteredBetItems =
      []; // Nouvelle liste pour les résultats filtrés
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(); // Contrôleur pour la recherche
  final TextEditingController _pointsController =
      TextEditingController(); // Contrôleur pour les points
  final BetItemStorage _storage = BetItemStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBetItems();

    // Écouter les changements dans le champ de recherche
    _searchController.addListener(_filterBetItems);
  }

  // Filtrer les éléments en fonction du texte de recherche
  void _filterBetItems() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredBetItems = List.from(_betItems);
      } else {
        _filteredBetItems = _betItems.where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Charger les éléments pariables depuis le stockage
  Future<void> _loadBetItems() async {
    final items = await _storage.loadBetItems();
    setState(() {
      _betItems = items;
      _filteredBetItems = List.from(items); // Initialiser la liste filtrée
      _isLoading = false;
    });
  }

  // Sauvegarder les éléments pariables dans le stockage
  Future<void> _saveBetItems() async {
    await _storage.saveBetItems(_betItems);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose(); // Libérer le contrôleur de recherche
    _pointsController.dispose(); // Libérer le contrôleur des points
    super.dispose();
  }

  void _addBetItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _betItems.add(
          BetItem(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            points: int.tryParse(_pointsController.text) ??
                1, // Utiliser la valeur des points
          ),
        );
        _filterBetItems(); // Mettre à jour la liste filtrée
      });
      _saveBetItems(); // Sauvegarder après ajout
      _nameController.clear();
      _descriptionController.clear();
      _pointsController.clear(); // Effacer le contrôleur des points
      Navigator.pop(context);
    }
  }

  void _editBetItem(BetItem item, int index) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _betItems[index] = BetItem(
          id: item.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          isScoring: item.isScoring,
          points: int.tryParse(_pointsController.text) ??
              1, // Utiliser la valeur des points
        );
        _filterBetItems(); // Mettre à jour la liste filtrée
      });
      _saveBetItems(); // Sauvegarder après modification
      _nameController.clear();
      _descriptionController.clear();
      _pointsController.clear(); // Effacer le contrôleur des points
      Navigator.pop(context);
    }
  }

  void _deleteBetItem(int index) {
    setState(() {
      _betItems.removeAt(index);
      _filterBetItems(); // Mettre à jour la liste filtrée
    });
    _saveBetItems(); // Sauvegarder après suppression
  }

  void _showAddEditDialog({BetItem? item, int? index}) {
    if (item != null) {
      _nameController.text = item.name;
      _descriptionController.text = item.description;
      _pointsController.text = item.points.toString(); // Initialiser les points
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _pointsController.text = "1"; // Initialiser les points à 1 par défaut
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          item == null ? 'Ajouter un élément' : 'Modifier l\'élément',
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }

                  // Vérifier s'il existe déjà un aliment avec ce nom
                  final trimmedValue = value.trim();
                  final isEditing = item != null;

                  // Lors de la modification, on ne vérifie pas le nom actuel de l'élément
                  bool alreadyExists = _betItems.any(
                    (betItem) =>
                        betItem.name.toLowerCase() ==
                            trimmedValue.toLowerCase() &&
                        (!isEditing || betItem.id != item.id),
                  );

                  if (alreadyExists) {
                    return 'Un aliment avec ce nom existe déjà';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                ),
              ),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  // Si le champ est vide, on utilisera la valeur par défaut (1)
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  // Si une valeur est spécifiée, elle doit être un nombre valide
                  final points = int.tryParse(value.trim());
                  if (points == null || points <= 0) {
                    return 'Veuillez entrer un nombre valide supérieur à 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (item == null) {
                _addBetItem();
              } else {
                _editBetItem(item, index!);
              }
            },
            child: Text(item == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Éléments Pariables'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Rechercher',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredBetItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun élément pariable trouvé.\nEssayez une autre recherche.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredBetItems.length,
                          itemBuilder: (ctx, index) {
                            final item = _filteredBetItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.description.isNotEmpty)
                                      Text(item.description),
                                    Text('Points: ${item.points}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showAddEditDialog(
                                        item: item,
                                        index: _betItems.indexOf(item),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteBetItem(
                                        _betItems.indexOf(item),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
