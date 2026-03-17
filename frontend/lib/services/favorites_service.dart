import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A small service for persisting a list of favorite product IDs.
///
/// This is intentionally lightweight and does not require a full state
/// management solution. The service exposes a ValueListenable that widgets
/// can listen to for updates.
class FavoritesService {
  FavoritesService._internal();

  static final FavoritesService instance = FavoritesService._internal();

  static const _prefsKey = 'favorite_product_ids';

  final ValueNotifier<Set<int>> favorites = ValueNotifier(const {});
  bool _initialized = false;

  Future<void> init() => _ensureInitialized();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? <String>[];
    favorites.value = stored
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();
    _initialized = true;
  }

  Future<void> toggleFavorite(int productId) async {
    await _ensureInitialized();
    final current = Set<int>.from(favorites.value);
    if (current.contains(productId)) {
      current.remove(productId);
    } else {
      current.add(productId);
    }
    favorites.value = current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      current.map((id) => id.toString()).toList(),
    );
  }

  Future<void> setFavorites(Set<int> productIds) async {
    await _ensureInitialized();
    favorites.value = Set<int>.from(productIds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      favorites.value.map((id) => id.toString()).toList(),
    );
  }

  Future<void> clearFavorites() async {
    await _ensureInitialized();
    favorites.value = {}; 
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<bool> isFavorite(int productId) async {
    await _ensureInitialized();
    return favorites.value.contains(productId);
  }
}
