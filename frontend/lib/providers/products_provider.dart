import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/product.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> products = [];

  bool isLoading = false;

  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    final data = await ApiService.getProducts();
    products = data.map((e) => Product.fromJson(e)).toList();

    isLoading = false;
    notifyListeners();
  }
}

