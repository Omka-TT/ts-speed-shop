import 'package:flutter/foundation.dart';

import '../services/order_service.dart';
import '../services/payment_service.dart';
import '../models/Order.dart';

/// A provider for managing order state.
///
class OrderProvider extends ChangeNotifier {
  Order? _currentOrder;
  List<Order> _orders = [];
  bool isLoading = false;

  Order? get currentOrder => _currentOrder;
  List<Order> get orders => _orders;

  /// Creates a new order from the current cart.
  /// Returns the created order data.
  Future<Order> createOrder() async {
    isLoading = true;
    notifyListeners();
    try {
      final orderData = await OrderService.instance.createOrder();
      _currentOrder = Order.fromJson(orderData);
      print('[OrderProvider] order created: ${_currentOrder!.id}');
      return _currentOrder!;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all user orders.
  Future<void> fetchOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      final ordersData = await OrderService.instance.getOrders();
      _orders =
          ordersData.map((orderData) => Order.fromJson(orderData)).toList();
      print('[OrderProvider] fetched ${_orders.length} orders');
    } catch (e) {
      print('Error fetching orders: $e');
      _orders = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes an order by ID.
  Future<void> deleteOrder(int orderId) async {
    try {
      await OrderService.instance.deleteOrder(orderId);
      _orders.removeWhere((order) => order.id == orderId);
      print('[OrderProvider] order $orderId deleted from local state');
      notifyListeners();
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  /// Clears the current order (useful after navigation or when starting fresh).
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// Clear all order data (used on logout)
  void clear() {
    _currentOrder = null;
    _orders = [];
    isLoading = false;
    print('[OrderProvider] orders cleared');
    notifyListeners();
  }

  /// Pays an order and updates local state.
  Future<void> payOrder(int orderId, {String paymentMethod = 'card'}) async {
    isLoading = true;
    notifyListeners();
    try {
      final paymentResult = await PaymentService.instance.payOrder(
        orderId,
        paymentMethod: paymentMethod,
      );

      // Update local order state
      _orders = _orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(status: 'paid');
        }
        return order;
      }).toList();

      if (_currentOrder != null && _currentOrder!.id == orderId) {
        _currentOrder = _currentOrder!.copyWith(status: 'paid');
      }

      print(
          '[OrderProvider] order $orderId marked as paid (payment id: ${paymentResult['id']})');
    } catch (e) {
      print('Error paying order: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the user's purchase history (completed orders).
  Future<void> fetchPurchaseHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      final ordersData = await OrderService.instance.getPurchaseHistory();
      _orders =
          ordersData.map((orderData) => Order.fromJson(orderData)).toList();
      print('[OrderProvider] fetched ${_orders.length} purchase history items');
    } catch (e) {
      print('Error fetching purchase history: $e');
      _orders = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
