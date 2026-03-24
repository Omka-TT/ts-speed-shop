import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'dio_client.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  /// Creates a payment for an order.
  ///
  /// Backend endpoint: POST /api/payments/
  /// Body: { "order_id": orderId, "payment_method": paymentMethod }
  /// Returns: Payment data with order marked as 'paid'
  Future<Map<String, dynamic>> payOrder(
    int orderId, {
    String paymentMethod = 'card',
  }) async {
    try {
      final response = await DioClient.instance.post(
        '/payments/',
        data: {
          'order_id': orderId,
          'payment_method': paymentMethod,
        },
      );

      // HTTP 201 = Payment created and order marked as paid
      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('Payment response is empty');
        }
        print('[PaymentService] Payment successful for order $orderId');
        return data;
      } else if (response.statusCode == 400) {
        // Validation error from backend
        final error = response.data?['error'] ?? 'Invalid payment data';
        throw Exception(error);
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        throw Exception(
          'Payment failed with status ${response.statusCode}: ${response.data}',
        );
      }
    } on DioException catch (e) {
      String errorMsg = 'Payment error';
      if (e.response?.statusCode == 400) {
        errorMsg = e.response?.data?['error'] ?? 'Invalid payment form';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'Order not found';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout. Check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Server not responding. Try again later.';
      } else {
        errorMsg = e.message ?? 'Payment network error';
      }
      print('[PaymentService] Error: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Legacy helper to keep old API shape if used elsewhere.
  static const String baseUrl = "http://127.0.0.1:8000/api/payments";

  static Future<Map<String, dynamic>> createPayment(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create payment");
    }
  }

  static Future<List<dynamic>> getMyPayments(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/my/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load payments");
    }
  }

  static Future<bool> uploadScreenshot(
    String token,
    int paymentId,
    File screenshot,
  ) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload-screenshot/$paymentId/"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "screenshot",
        screenshot.path,
      ),
    );

    var response = await request.send();

    return response.statusCode == 200;
  }

  static Future<bool> confirmPayment(
    String token,
    int paymentId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/confirm/$paymentId/"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
}