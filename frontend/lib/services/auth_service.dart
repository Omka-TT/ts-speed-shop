import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api",
      headers: {
        "Content-Type": "application/json"
      },
      validateStatus: (status) {
        return status! < 500; // Принимаем все статусы кроме 500+
      },
    )
  );

  Future<Map<String, dynamic>> login(String username, String email, String password) async {
    try {
      final response = await dio.post(
        "/auth/login/",
        data: {
          "username": username,
          "email": email,
          "password": password
        },
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Data: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Login successful',
          'data': response.data,
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

