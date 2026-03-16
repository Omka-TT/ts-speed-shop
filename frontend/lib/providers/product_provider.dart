import 'package:flutter/material.dart';
import '../models/Product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Загрузка продуктов с сервера
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _error = 'Failed to load products';
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Получение популярных продуктов
  List<Product> get popularProducts {
    return _products.where((p) => p.isPopular).toList();
  }

  // Получение продукта по ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Переключение избранного
  Future<void> toggleFavorite(int productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isFavourite: !_products[index].isFavourite,
      );
      notifyListeners();
    }
  }
}

