import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/Product.dart';
import 'auth_service.dart';
import 'dio_client.dart';

/// A service for managing user favorites via backend API.
///
class FavoritesService {
  FavoritesService._internal();

  static final FavoritesService instance = FavoritesService._internal();

  /// Fetches the user's favorite products from the backend.
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await DioClient.instance.get('/favorites/');
      if (response.statusCode == 200) {
        final data = response.data;
        print('[FavoritesService] response data: $data');
        if (data is List) {
          final favorites = data.map((item) => item as Map<String, dynamic>).toList();
          print('[FavoritesService] fetched ${favorites.length} favorites');
          return favorites;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[FavoritesService] error fetching favorites: $e');
      throw Exception('Network error while loading favorites');
    }
  }

  /// Adds a product to the user's favorites.
  Future<void> addToFavorites(int productId) async {
    try {
      print('[FavoritesService] sending request body: {"product_id": $productId}');
      final response = await DioClient.instance.post(
        '/favorites/',
        data: {'product_id': productId},
      );
      if (response.statusCode == 201) {
        print('[FavoritesService] added product $productId to favorites');
      } else {
        throw Exception('Failed to add favorite: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[FavoritesService] error adding favorite: $e');
      throw Exception('Network error while adding favorite');
    }
  }

  /// Removes a product from the user's favorites.
  Future<void> removeFromFavorites(int favoriteId) async {
    try {
      print('[FavoritesService] deleting favorite with id: $favoriteId');
      final response = await DioClient.instance.delete('/favorites/$favoriteId/');
      if (response.statusCode == 204) {
        print('[FavoritesService] removed favorite $favoriteId');
      } else {
        throw Exception('Failed to remove favorite: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[FavoritesService] error removing favorite: $e');
      throw Exception('Network error while removing favorite');
    }
  }
}
