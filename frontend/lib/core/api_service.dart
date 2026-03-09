import 'dart:convert';
import 'package:http/http.dart' as http;

/// Базовый URL вашего backend
const String baseUrl = 'http://10.0.2.2:8000/api'; // для эмулятора Android

class ApiService {
  static String? token;

  /// Получить список продуктов
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  /// Авторизация
  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      token = data['access'];
    } else {
      throw Exception('Login failed');
    }
  }

  /// Регистрация
  static Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'password2': password
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Registration failed');
    }
  }
}

