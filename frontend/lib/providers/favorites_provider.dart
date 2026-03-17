import 'package:flutter/foundation.dart';

import '../models/Product.dart';
import '../services/favorites_service.dart';

/// A simple global favorites store that keeps a set of favorite product IDs
/// and exposes helper methods for toggling and querying favorites.
///
/// Uses [FavoritesService] for persistence across app restarts.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider() {
    _initialize();
  }

  final Set<int> _favoriteIds = {};
  bool _initialized = false;

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(Product product) => _favoriteIds.contains(product.id);

  Future<void> toggleFavorite(Product product) async {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
    } else {
      _favoriteIds.add(product.id);
    }
    notifyListeners();
    await FavoritesService.instance.setFavorites(_favoriteIds);
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    // FavoritesService is initialized during app startup (main.dart). Here we
    // just sync the local cache and subscribe to changes.
    _favoriteIds
      ..clear()
      ..addAll(FavoritesService.instance.favorites.value);
    _initialized = true;
    notifyListeners();

    // Listen for external changes to persistence.
    FavoritesService.instance.favorites.addListener(() {
      _favoriteIds
        ..clear()
        ..addAll(FavoritesService.instance.favorites.value);
      notifyListeners();
    });
  }
}
