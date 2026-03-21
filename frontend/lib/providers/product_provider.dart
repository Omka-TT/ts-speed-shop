import 'package:flutter/foundation.dart';

import '../models/Product.dart';
import '../services/product_service.dart';

/// A simple data provider that fetches products from the backend and keeps separate
/// lists for products vs courses.
///
/// This can be used with `Provider` to keep UI in sync and avoid duplicate
/// network requests across multiple screens.
class ProductProvider extends ChangeNotifier {
  List<Product> products = [];
  List<Product> courses = [];
  bool isLoading = false;
  Object? error;

  Future<void> fetchProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ProductService().getProducts();

      products = data.where((e) => e.type == "product").toList();
      courses = data.where((e) => e.type == "course").toList();
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchProducts();
}
