import 'package:dio/dio.dart';

class OrderService {

  static const url = "http://127.0.0.1:8000/api/orders/";

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: url,
    )
  );

}