import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/register_service.dart';

/// A provider for managing authentication state.
///
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _currentUserId;
  String? _currentUsername;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;
  String? get currentUsername => _currentUsername;

  /// Initialize auth state on app startup
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.instance.getToken();
      _isLoggedIn = token != null && token.isNotEmpty;

      if (_isLoggedIn) {
        print('[AuthProvider] User is logged in with token');
      } else {
        print('[AuthProvider] No valid token found - user not logged in');
      }
    } catch (e) {
      print('[AuthProvider] Error initializing auth state: $e');
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user and update state
  Future<bool> login(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.instance.login(username, email, password);

      if (result['success'] == true) {
        _isLoggedIn = true;
        _currentUsername = username;
        print('[AuthProvider] Login successful for user: $username');
        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        print('[AuthProvider] Login failed: ${result['message']}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoggedIn = false;
      print('[AuthProvider] Login error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register user and update state
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final registerService = RegisterService();
      final result = await registerService.register(username, email, password);

      if (result['success'] == true) {
        // Extract token from register response if available
        final data = result['data'];
        if (data is Map) {
          final token = (data['token'] ?? data['key'] ?? data['access'])?.toString();
          if (token != null && token.isNotEmpty) {
            await AuthService.instance.saveToken(token);
            print('[AuthProvider] Token saved after registration');
          }
        }

        _isLoggedIn = true;
        _currentUsername = username;
        print('[AuthProvider] Registration successful for user: $username');
        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        print('[AuthProvider] Registration failed: ${result['message']}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoggedIn = false;
      print('[AuthProvider] Registration error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user and clear all state
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.instance.clearToken();
      _isLoggedIn = false;
      _currentUserId = null;
      _currentUsername = null;
      print('[AuthProvider] Logout successful');
    } catch (e) {
      print('[AuthProvider] Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update current user info (called after profile fetch)
  void updateUserInfo({String? userId, String? username}) {
    if (userId != null) _currentUserId = userId;
    if (username != null) _currentUsername = username;
    notifyListeners();
  }
}