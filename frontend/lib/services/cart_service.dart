import 'package:dio/dio.dart';

import 'dio_client.dart';

/// A service for managing cart items via backend API.
///
class CartService {
  CartService._internal();

  static final CartService instance = CartService._internal();

  /// Fetches the user's cart items from the backend.
  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final response = await DioClient.instance.get('/cart/');
      if (response.statusCode == 200) {
        final data = response.data;
        print('[CartService] response data: $data');
        if (data is List) {
          final cartItems = data.map((item) => item as Map<String, dynamic>).toList();
          print('[CartService] fetched ${cartItems.length} cart items');
          return cartItems;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[CartService] error fetching cart: $e');
      throw Exception('Network error while loading cart');
    }
  }

  /// Adds a product to the user's cart with specified quantity.
  Future<void> addToCart(int productId, {int quantity = 1}) async {
    try {
      print('[CartService] sending request body: {"product_id": $productId, "quantity": $quantity}');
      final response = await DioClient.instance.post(
        '/cart/',
        data: {'product_id': productId, 'quantity': quantity},
      );
      if (response.statusCode == 201) {
        print('[CartService] added product $productId to cart with quantity $quantity');
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[CartService] error adding to cart: $e');
      throw Exception('Network error while adding to cart');
    }
  }

  /// Updates the quantity of a cart item.
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    try {
      print('[CartService] updating cart item $cartItemId with quantity: $quantity');
      final response = await DioClient.instance.patch(  // Use PATCH for partial update
        '/cart/$cartItemId/',
        data: {'quantity': quantity},
      );
      if (response.statusCode == 200) {
        print('[CartService] updated cart item $cartItemId to quantity $quantity');
      } else {
        throw Exception('Failed to update cart item: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[CartService] error updating cart item: $e');
      throw Exception('Network error while updating cart item');
    }
  }

  /// Removes a cart item from the user's cart.
  Future<void> removeFromCart(int cartItemId) async {
    try {
      print('[CartService] deleting cart item with id: $cartItemId');
      final response = await DioClient.instance.delete('/cart/$cartItemId/');
      if (response.statusCode == 204) {
        print('[CartService] removed cart item $cartItemId');
      } else {
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[CartService] error removing from cart: $e');
      throw Exception('Network error while removing from cart');
    }
  }
}


