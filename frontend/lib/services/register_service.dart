import 'package:dio/dio.dart';

class RegisterService {

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api",
    )
  );

  Future<bool> register(
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

      return response.statusCode == 200 ||
             response.statusCode == 201;

    } catch(e) {

      print(e);
      return false;

    }

  }

}