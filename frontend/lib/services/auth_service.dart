import 'package:dio/dio.dart';

class AuthService {

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api",
      headers: {
        "Content-Type": "application/json"
      }
    )
  );

  Future<bool> login(String username,String email,String password) async {

    try {

      final response = await dio.post(
        "/auth/login/",
        data: {
          "username": username,
          "email": email,
          "password": password
        }
      );

      return response.statusCode == 200;

    } catch(e) {

      print(e);
      return false;

    }

  }

}

