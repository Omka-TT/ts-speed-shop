import 'package:dio/dio.dart';
import '../models/Cart.dart';
import '../models/Product.dart';

class CartService {
  late Dio dio;
  
  CartService() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:8000/api",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
  }

  // Получение корзины с сервера
  Future<List<Cart>> getCart() async {
    try {
      final response = await dio.get("/cart/");
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => Cart.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  // Добавление товара в корзину на сервере
  Future<bool> addToCart(Product product, int quantity) async {
    try {
      final response = await dio.post(
        "/cart/add/",
        data: {
          'product_id': product.id,
          'quantity': quantity,
        },
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Обновление количества товара
  Future<bool> updateCartItem(int productId, int quantity) async {
    try {
      final response = await dio.put(
        "/cart/update/$productId/",
        data: {'quantity': quantity},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating cart: $e');
      return false;
    }
  }

  // Удаление товара из корзины
  Future<bool> removeFromCart(int productId) async {
    try {
      final response = await dio.delete("/cart/remove/$productId/");
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Очистка корзины
  Future<bool> clearCart() async {
    try {
      final response = await dio.delete("/cart/clear/");
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}


