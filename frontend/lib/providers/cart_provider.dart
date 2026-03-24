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

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      await CartService.instance.addToCart(product.id, quantity: quantity);
      print('[CartProvider] added product ${product.id} to cart with quantity $quantity');
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

  Future<void> increaseQuantity(int cartItemId) async {
    try {
      final item = _cartItems.firstWhere((item) => item['id'] == cartItemId);
      final newQuantity = (item['quantity'] ?? 1) + 1;
      await CartService.instance.updateCartItem(cartItemId, newQuantity);
      print('[CartProvider] increased quantity of cart item $cartItemId to $newQuantity');
      // Refetch to get updated cart
      await fetchCartItems();
    } catch (e) {
      print('Error increasing quantity: $e');
      rethrow;
    }
  }

  Future<void> decreaseQuantity(int cartItemId) async {
    try {
      final item = _cartItems.firstWhere((item) => item['id'] == cartItemId);
      final currentQuantity = item['quantity'] ?? 1;
      if (currentQuantity <= 1) {
        // Remove item if quantity would be 0
        await removeFromCart(cartItemId);
      } else {
        final newQuantity = currentQuantity - 1;
        await CartService.instance.updateCartItem(cartItemId, newQuantity);
        print('[CartProvider] decreased quantity of cart item $cartItemId to $newQuantity');
        // Refetch to get updated cart
        await fetchCartItems();
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
      rethrow;
    }
  }

  bool isInCart(Product product) => _cartItems.any((item) => item['product']['id'] == product.id);

  /// Clear all cart data (used on logout)
  void clear() {
    _cartItems = [];
    isLoading = false;
    print('[CartProvider] cart cleared');
    notifyListeners();
  }
}