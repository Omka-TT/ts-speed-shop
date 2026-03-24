import 'package:dio/dio.dart';

import '../models/Product.dart';
import 'auth_service.dart';
import 'dio_client.dart';

/// Exception thrown when an authenticated API call fails due to missing/invalid token.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when product fetching fails for any other reason.
class ProductServiceException implements Exception {
  final String message;
  ProductServiceException(this.message);

  @override
  String toString() => 'ProductServiceException: $message';
}

class ProductService {
  ProductService();

  /// Fetches products from the backend API using the stored auth token.
  ///
  /// Throws [AuthException] when the token is missing or invalid.
  /// Throws [ProductServiceException] for other failures.
  Future<List<Product>> getProducts() async {
    try {
      final response = await DioClient.instance.get(
        '/products/',
        options: Options(extra: {'requiresAuth': false}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final products = <Product>[];
        if (data is List) {
          products.addAll(
            data.map((item) => Product.fromJson(item as Map<String, dynamic>)),
          );
        } else if (data is Map && data['results'] != null) {
          products.addAll(
            (data['results'] as List)
                .map((item) => Product.fromJson(item as Map<String, dynamic>)),
          );
        }

        print('[ProductService] parsed products: ${products.length}');
        return products;
      }

      if (response.statusCode == 401) {
        // Token is invalid / expired.
        await AuthService.instance.clearToken();
        throw AuthException('Session expired. Please log in again.');
      }

      throw ProductServiceException(
          'Server returned status ${response.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ProductServiceException('Network error. Please check your connection.');
      }

      // 401 may come here as well if validateStatus allows it.
      if (e.response?.statusCode == 401) {
        await AuthService.instance.clearToken();
        throw AuthException('Session expired. Please log in again.');
      }

      throw ProductServiceException('Failed to load products: ${e.message}');
    } catch (e) {
      throw ProductServiceException('Failed to load products.');
    }
  }
}

