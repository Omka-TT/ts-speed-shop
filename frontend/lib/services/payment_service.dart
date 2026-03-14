import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class PaymentService {

  static const String baseUrl = "http://127.0.0.1:8000/api/payments";

  /// CREATE PAYMENT
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

  /// GET MY PAYMENTS
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

  /// UPLOAD SCREENSHOT
  static Future<bool> uploadScreenshot(
      String token,
      int paymentId,
      File screenshot
      ) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload-screenshot/$paymentId/")
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "screenshot",
        screenshot.path
      )
    );

    var response = await request.send();

    return response.statusCode == 200;

  }

  /// CONFIRM PAYMENT (admin)
  static Future<bool> confirmPayment(
      String token,
      int paymentId
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