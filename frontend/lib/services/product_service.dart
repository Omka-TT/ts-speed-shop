import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Product.dart';

const _kAuthTokenKey = 'auth_token';

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
  final Dio _dio;

  ProductService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://127.0.0.1:8000/api',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) {
              // Accept 4xx errors so we can handle them explicitly.
              return status != null && status < 500;
            },
          ),
        ) {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAuthTokenKey);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthTokenKey);
  }

  /// Fetches products from the backend API using the stored auth token.
  ///
  /// Throws [AuthException] when the token is missing or invalid.
  /// Throws [ProductServiceException] for other failures.
  Future<List<Product>> getProducts() async {
    final token = await _readToken();

    if (token == null || token.isEmpty) {
      throw AuthException('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await _dio.get(
        '/products/',
        options: Options(
          headers: {
            'Authorization': 'Token $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          return data
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        if (data is Map && data['results'] != null) {
          return (data['results'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        return [];
      }

      if (response.statusCode == 401) {
        // Token is invalid / expired.
        await _clearToken();
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
        await _clearToken();
        throw AuthException('Session expired. Please log in again.');
      }

      throw ProductServiceException('Failed to load products: ${e.message}');
    } catch (e) {
      throw ProductServiceException('Failed to load products.');
    }
  }
}

