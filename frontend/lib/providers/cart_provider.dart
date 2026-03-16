import 'package:flutter/material.dart';
import '../models/Cart.dart';
import '../models/Product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<Cart> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<Cart> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Загрузка корзины с сервера
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCart();
    } catch (e) {
      _error = 'Failed to load cart';
      print('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Добавление товара в корзину
  Future<bool> addToCart(Product product, int quantity) async {
    try {
      final success = await _cartService.addToCart(product, quantity);
      if (success) {
        await loadCart(); // Перезагружаем корзину после добавления
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Обновление количества товара
  Future<bool> updateCartItem(int productId, int quantity) async {
    try {
      final success = await _cartService.updateCartItem(productId, quantity);
      if (success) {
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating cart: $e');
      return false;
    }
  }

  // Удаление товара из корзины
  Future<bool> removeFromCart(int productId) async {
    try {
      final success = await _cartService.removeFromCart(productId);
      if (success) {
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Очистка корзины
  Future<bool> clearCart() async {
    try {
      final success = await _cartService.clearCart();
      if (success) {
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // Подсчет общего количества товаров
  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.numOfItem);
  }

  // Подсчет общей стоимости
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

