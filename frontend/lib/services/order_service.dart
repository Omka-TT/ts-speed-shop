import 'package:dio/dio.dart';

import 'dio_client.dart';

/// A service for managing orders via backend API.
///
class OrderService {
  OrderService._internal();

  static final OrderService instance = OrderService._internal();

  /// Creates a new order from the current cart items.
  /// The backend handles converting cart items to order items and clearing the cart.
  Future<Map<String, dynamic>> createOrder() async {
    try {
      print('[OrderService] creating order from cart');
      final response = await DioClient.instance.post('/orders/');
      if (response.statusCode == 201) {
        final orderData = response.data as Map<String, dynamic>;
        print('[OrderService] order created successfully: ${orderData['id']}');
        return orderData;
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[OrderService] error creating order: $e');
      throw Exception('Network error while creating order');
    }
  }

  /// Fetches the user's orders from the backend.
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await DioClient.instance.get('/orders/');
      if (response.statusCode == 200) {
        final data = response.data;
        print('[OrderService] response data: $data');
        if (data is List) {
          final orders = data.map((item) => item as Map<String, dynamic>).toList();
          print('[OrderService] fetched ${orders.length} orders');
          return orders;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[OrderService] error fetching orders: $e');
      throw Exception('Network error while loading orders');
    }
  }

  /// Deletes an order by ID.
  Future<void> deleteOrder(int orderId) async {
    try {
      print('[OrderService] deleting order $orderId');
      final response = await DioClient.instance.delete('/orders/$orderId/');
      if (response.statusCode == 204) {
        print('[OrderService] order $orderId deleted successfully');
      } else {
        throw Exception('Failed to delete order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[OrderService] error deleting order: $e');
      throw Exception('Network error while deleting order');
    }
  }

  /// Fetches the user's purchase history (completed orders).
  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    try {
      final response = await DioClient.instance.get('/orders/purchase-history/');
      if (response.statusCode == 200) {
        final data = response.data;
        print('[OrderService] response data: $data');
        if (data is List) {
          final orders = data.map((item) => item as Map<String, dynamic>).toList();
          print('[OrderService] fetched ${orders.length} purchase history items');
          return orders;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load purchase history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[OrderService] error fetching purchase history: $e');
      throw Exception('Network error while loading purchase history');
    }
  }
}