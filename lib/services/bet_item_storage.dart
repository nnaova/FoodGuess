import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bet_item.dart';

class BetItemStorage {
  static const String _storageKey = 'bet_items';

  // Sauvegarder la liste des éléments pariables
  Future<void> saveBetItems(List<BetItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // Charger la liste des éléments pariables
  Future<List<BetItem>> loadBetItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((itemJson) => BetItem.fromJson(itemJson)).toList();
    } catch (e) {
      // Utilisation de debugPrint en mode debug seulement
      debugPrint('Erreur lors du chargement des éléments pariables: $e');
      return [];
    }
  }
}
