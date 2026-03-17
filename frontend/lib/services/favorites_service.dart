import 'dart:convert';

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

  static const _prefsKeyBase = 'favorite_product_ids';

  final ValueNotifier<Set<int>> favorites = ValueNotifier(const {});
  bool _initialized = false;
  String? _userToken;

  Future<void> init({String? userToken}) async {
    await setUserToken(userToken);
  }

  Future<void> setUserToken(String? userToken) async {
    // Keep the token stable to ensure favorites are stored per user.
    final normalized = (userToken?.trim().isEmpty ?? true) ? null : userToken;
    if (_userToken == normalized && _initialized) return;

    _userToken = normalized;
    _initialized = false;
    await _ensureInitialized();
  }

  String _prefsKeyForCurrentUser() {
    if (_userToken == null) return _prefsKeyBase;
    // Use a stable encoding of the token so that the same user always maps to
    // the same key across app restarts.
    final encoded = base64Url.encode(utf8.encode(_userToken!));
    return '${_prefsKeyBase}_$encoded';
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKeyForCurrentUser()) ?? <String>[];
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
      _prefsKeyForCurrentUser(),
      current.map((id) => id.toString()).toList(),
    );
  }

  Future<void> setFavorites(Set<int> productIds) async {
    await _ensureInitialized();
    favorites.value = Set<int>.from(productIds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKeyForCurrentUser(),
      favorites.value.map((id) => id.toString()).toList(),
    );
  }

  Future<void> clearFavorites() async {
    await _ensureInitialized();
    favorites.value = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyForCurrentUser());
  }

  Future<bool> isFavorite(int productId) async {
    await _ensureInitialized();
    return favorites.value.contains(productId);
  }
}
