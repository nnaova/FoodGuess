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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BetItemStorage _storage = BetItemStorage();
  bool _isLoading = true;

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

  // Sauvegarder les éléments pariables dans le stockage
  Future<void> _saveBetItems() async {
    await _storage.saveBetItems(_betItems);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
          ),
        );
      });
      _saveBetItems(); // Sauvegarder après ajout
      _nameController.clear();
      _descriptionController.clear();
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
        );
      });
      _saveBetItems(); // Sauvegarder après modification
      _nameController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }
  }

  void _deleteBetItem(int index) {
    setState(() {
      _betItems.removeAt(index);
    });
    _saveBetItems(); // Sauvegarder après suppression
  }

  void _showAddEditDialog({BetItem? item, int? index}) {
    if (item != null) {
      _nameController.text = item.name;
      _descriptionController.text = item.description;
    } else {
      _nameController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                      bool alreadyExists = _betItems.any((betItem) => 
                        betItem.name.toLowerCase() == trimmedValue.toLowerCase() && 
                        (!isEditing || betItem.id != item.id)
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _betItems.isEmpty
              ? const Center(
                child: Text(
                  'Aucun élément pariable ajouté.\nAppuyez sur le bouton + pour en ajouter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: _betItems.length,
                itemBuilder: (ctx, index) {
                  final item = _betItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle:
                          item.description.isNotEmpty
                              ? Text(item.description)
                              : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _showAddEditDialog(
                                  item: item,
                                  index: index,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBetItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
