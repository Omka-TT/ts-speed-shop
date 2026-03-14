import 'package:dio/dio.dart';
import '../models/Product.dart';

class ProductService {
  late Dio dio;
  
  ProductService() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:8000/api",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Получение списка продуктов
  Future<List<Product>> getProducts() async {
    try {
      print('🌐 Fetching products from API...');
      final response = await dio.get("/products/");
      
      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List<Product> products = [];
        
        if (response.data is List) {
          // Если API возвращает массив
          products = (response.data as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map && response.data['results'] != null) {
          // Если API возвращает пагинированный ответ
          products = (response.data['results'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        
        print('✅ Loaded ${products.length} products');
        return products;
      }
      return [];
    } on DioException catch (e) {
      print('❌ DioError in getProducts: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error in getProducts: $e');
      return [];
    }
  }

  // Получение одного продукта по ID
  Future<Product?> getProductById(int id) async {
    try {
      print('🌐 Fetching product with ID: $id');
      final response = await dio.get("/products/$id/");
      
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('❌ DioError in getProductById: ${e.message}');
      return null;
    }
  }
}


