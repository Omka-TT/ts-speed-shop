import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dio_client.dart';
import 'favorites_service.dart';

const _kAuthTokenKey = 'auth_token';

/// Thrown when an authenticated request is made but no valid token is present.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  static const String authTokenKey = _kAuthTokenKey;

  bool _initialized = false;
  String? _token;

  /// Loads the token from persistent storage.
  ///
  /// This should be called early in application startup so that the token is
  /// available for all subsequent requests.
  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kAuthTokenKey);
    _initialized = true;

    print('[AuthService] token loaded: ${_token != null}');

    // Favorites are handled via Dio interceptor
  }

  /// Returns the current token, loading it from storage if necessary.
  Future<String?> getToken() async {
    if (!_initialized) await init();

    final trimmed = _token?.trim();
    final hasToken = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    print('[AuthService] getToken() returning: ${hasToken != null ? '***${hasToken.substring(max(0, hasToken.length - 4))}' : 'null'}');
    return hasToken;
  }

  /// Saves a token to persistent storage and updates the in-memory cache.
  Future<void> saveToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;

    _token = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthTokenKey, trimmed);

    print('[AuthService] token saved (length ${trimmed.length})');
  }

  /// Clears stored token and related state.
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthTokenKey);

    print('[AuthService] token cleared');
  }

  Future<Map<String, dynamic>> login(String username, String email, String password) async {
    try {
      final response = await DioClient.instance.post(
        "/auth/login/",
        data: {
          "username": username,
          "email": email,
          "password": password
        },
        options: Options(extra: {'requiresAuth': false}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // dj-rest-auth token endpoint returns {"key": "..."}
        // SimpleJWT returns {"access": "...", "refresh": "..."}
        final data = response.data is Map ? response.data as Map : <String, dynamic>{};
        final token = (data['token'] ?? data['key'] ?? data['access'])?.toString();

        if (token != null && token.isNotEmpty) {
          await saveToken(token);
        } else {
          print('Login success but no token found in response: ${response.data}');
        }

        return {
          'success': true,
          'message': 'Login successful',
          'data': response.data,
          'token': token,
        };
      } else if (response.statusCode == 400) {
        // Обработка ошибки 400 (неверные данные или пользователь не найден)
        String errorMessage = 'Invalid credentials';
        String? fieldError;
        
        if (response.data is Map) {
          if (response.data['error'] != null) {
            errorMessage = response.data['error'].toString();
          } else if (response.data['message'] != null) {
            errorMessage = response.data['message'].toString();
          } else if (response.data['detail'] != null) {
            errorMessage = response.data['detail'].toString();
          }
          
          // Определяем, какое поле вызвало ошибку
          if (errorMessage.toLowerCase().contains('username') || 
              errorMessage.toLowerCase().contains('user not found')) {
            fieldError = 'username';
          } else if (errorMessage.toLowerCase().contains('email')) {
            fieldError = 'email';
          } else if (errorMessage.toLowerCase().contains('password')) {
            fieldError = 'password';
          }
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'fieldError': fieldError,
          'statusCode': 400,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid username or password',
          'fieldError': 'credentials',
          'statusCode': 401,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not registered. Please sign up first.',
          'fieldError': 'user_not_found',
          'statusCode': 404,
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed with status code: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } on DioError catch (e) {
      print('DioError in login: $e');
      
      if (e.response != null) {
        print('Error response status: ${e.response?.statusCode}');
        print('Error response data: ${e.response?.data}');
        
        // Обработка 404 ошибки
        if (e.response?.statusCode == 404) {
          return {
            'success': false,
            'message': 'User not registered. Please sign up first.',
            'fieldError': 'user_not_found',
            'statusCode': 404,
          };
        }
        // Обработка 400 ошибки
        else if (e.response?.statusCode == 400) {
          String errorMessage = 'Invalid credentials';
          String? fieldError;
          
          if (e.response?.data != null) {
            if (e.response?.data is Map) {
              final data = e.response?.data as Map;
              if (data.containsKey('username') || data.containsKey('email')) {
                fieldError = 'username_email';
                errorMessage = 'Username or email already exists';
              } else if (data.containsKey('password')) {
                fieldError = 'password';
                errorMessage = 'Invalid password';
              } else if (data['error'] != null) {
                errorMessage = data['error'].toString();
                if (errorMessage.toLowerCase().contains('not registered')) {
                  fieldError = 'user_not_found';
                }
              }
            }
          }
          
          return {
            'success': false,
            'message': errorMessage,
            'fieldError': fieldError,
            'statusCode': 400,
          };
        }
        
        return {
          'success': false,
          'message': 'Server error: ${e.response?.statusCode}',
          'statusCode': e.response?.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': 'Network error. Please check your connection.',
          'fieldError': 'network',
        };
      }
    } catch (e) {
      print('Unexpected error in login: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
}