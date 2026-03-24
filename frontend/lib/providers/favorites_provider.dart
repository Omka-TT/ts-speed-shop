import 'package:flutter/foundation.dart';

import '../models/Product.dart';
import '../services/favorites_service.dart';

/// A simple global favorites store that keeps a list of favorite products
/// and exposes helper methods for toggling and querying favorites.
///
class FavoritesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favoritesData = [];
  bool isLoading = false;

  List<Product> get favorites => _favoritesData.map((f) => Product.fromJson(f['product'])).toList();

  Future<void> fetchFavorites() async {
    isLoading = true;
    notifyListeners();
    try {
      _favoritesData = await FavoritesService.instance.getFavorites();
      print('[FavoritesProvider] fetched ${favorites.length} favorites');
    } catch (e) {
      print('Error fetching favorites: $e');
      _favoritesData = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final isCurrentlyFavorite = favorites.any((f) => f.id == product.id);
    try {
      if (isCurrentlyFavorite) {
        // Find the favorite id
        final favoriteData = _favoritesData.firstWhere((f) => f['product']['id'] == product.id);
        final favoriteId = favoriteData['id'];
        await FavoritesService.instance.removeFromFavorites(favoriteId);
        _favoritesData.removeWhere((f) => f['id'] == favoriteId);
        print('[FavoritesProvider] removed favorite for product ${product.id}');
      } else {
        await FavoritesService.instance.addToFavorites(product.id);
        print('[FavoritesProvider] added favorite for product ${product.id}');
        // Refetch to get the new favorite data
        await fetchFavorites();
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
      // Refetch to ensure consistency
      await fetchFavorites();
    }
  }

  bool isFavorite(Product product) => favorites.any((f) => f.id == product.id);

  /// Clear all favorites data (used on logout)
  void clear() {
    _favoritesData = [];
    isLoading = false;
    print('[FavoritesProvider] favorites cleared');
    notifyListeners();
  }
}
