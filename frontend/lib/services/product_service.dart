import 'package:dio/dio.dart';

class ProductService {

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api",
    )
  );

  Future<List> getProducts() async {

    final response = await dio.get("/products/");

    return response.data;

  }

}

