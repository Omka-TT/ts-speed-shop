import 'package:flutter/foundation.dart';

import '../models/Product.dart';
import '../services/cart_service.dart';

/// A provider for managing cart state.
///
class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  bool isLoading = false;

  List<Map<String, dynamic>> get cartItems => _cartItems;

  int get cartItemCount => _cartItems.length;

  Future<void> fetchCartItems() async {
    isLoading = true;
    notifyListeners();
    try {
      _cartItems = await CartService.instance.getCartItems();
      print('[CartProvider] fetched ${cartItems.length} cart items');
    } catch (e) {
      print('Error fetching cart items: $e');
      _cartItems = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product) async {
    try {
      await CartService.instance.addToCart(product.id);
      print('[CartProvider] added product ${product.id} to cart');
      // Refetch to get updated cart
      await fetchCartItems();
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      await CartService.instance.removeFromCart(cartItemId);
      _cartItems.removeWhere((item) => item['id'] == cartItemId);
      print('[CartProvider] removed cart item $cartItemId');
      notifyListeners();
    } catch (e) {
      print('Error removing from cart: $e');
      // Refetch to ensure consistency
      await fetchCartItems();
    }
  }

  bool isInCart(Product product) => _cartItems.any((item) => item['product']['id'] == product.id);
}