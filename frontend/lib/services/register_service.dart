import 'package:dio/dio.dart';

class RegisterService {
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

  Future<Map<String, dynamic>> register(
      String username,
      String email,
      String password) async {
    
    try {
      final response = await dio.post(
        "/auth/register/",
        data: {
          "username": username,
          "email": email,
          "password": password
        },
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registration successful',
          'data': response.data,
        };
      } else if (response.statusCode == 400) {
        // Обработка ошибки 400 (пользователь уже существует или неверные данные)
        String errorMessage = 'Registration failed';
        Map<String, String> fieldErrors = {};
        
        if (response.data is Map) {
          final data = response.data as Map;
          
          // Проверяем наличие ошибок по полям
          if (data.containsKey('username')) {
            String usernameError = data['username'].toString();
            fieldErrors['username'] = usernameError.contains('already exists') 
                ? 'Username already taken' 
                : 'Invalid username';
            errorMessage = usernameError;
          }
          
          if (data.containsKey('email')) {
            String emailError = data['email'].toString();
            fieldErrors['email'] = emailError.contains('already exists') 
                ? 'Email already registered' 
                : 'Invalid email';
            errorMessage = emailError;
          }
          
          if (data.containsKey('password')) {
            fieldErrors['password'] = 'Password is too weak';
          }
          
          // Общие ошибки
          if (data['error'] != null) {
            errorMessage = data['error'].toString();
            if (errorMessage.toLowerCase().contains('already')) {
              fieldErrors['username'] = 'Username already taken';
              fieldErrors['email'] = 'Email already registered';
            }
          }
          
          if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
          
          if (data['detail'] != null) {
            errorMessage = data['detail'].toString();
          }
        }
        
        // Проверяем, есть ли ошибка о существующем пользователе
        bool userExists = errorMessage.toLowerCase().contains('already') || 
                          errorMessage.toLowerCase().contains('exists') ||
                          fieldErrors.containsKey('username') ||
                          fieldErrors.containsKey('email');
        
        return {
          'success': false,
          'message': errorMessage,
          'fieldErrors': fieldErrors,
          'userExists': userExists,
          'statusCode': 400,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed with status code: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } on DioError catch (e) {
      print('DioError in register: $e');
      
      if (e.response != null) {
        print('Error response status: ${e.response?.statusCode}');
        print('Error response data: ${e.response?.data}');
        
        if (e.response?.statusCode == 400) {
          Map<String, String> fieldErrors = {};
          String errorMessage = 'Registration failed';
          bool userExists = false;
          
          if (e.response?.data != null && e.response?.data is Map) {
            final data = e.response?.data as Map;
            
            // Проверяем наличие ошибок по полям
            if (data.containsKey('username')) {
              String usernameError = data['username'].toString();
              fieldErrors['username'] = usernameError.contains('already exists') 
                  ? 'Username already taken' 
                  : 'Invalid username';
              userExists = true;
            }
            
            if (data.containsKey('email')) {
              String emailError = data['email'].toString();
              fieldErrors['email'] = emailError.contains('already exists') 
                  ? 'Email already registered' 
                  : 'Invalid email';
              userExists = true;
            }
            
            if (data.containsKey('password')) {
              fieldErrors['password'] = 'Password is too weak';
            }
            
            if (data['error'] != null) {
              errorMessage = data['error'].toString();
              if (errorMessage.toLowerCase().contains('already')) {
                userExists = true;
              }
            }
            
            if (data['message'] != null) {
              errorMessage = data['message'].toString();
            }
          }
          
          return {
            'success': false,
            'message': errorMessage,
            'fieldErrors': fieldErrors,
            'userExists': userExists,
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
      print('Unexpected error in register: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
}

