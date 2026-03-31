import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/Order.dart';
import '../../screens/order/order_details_page.dart';
import '../../constants.dart';

class OrderPage extends StatefulWidget {
  static String routeName = "/order";

  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    // Fetch all orders when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _deleteOrder(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete Order #${order.id}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<OrderProvider>().deleteOrder(order.id);
        if (mounted) {
          // Show deletion success notification (TOP)
          context.read<NotificationProvider>().addNotification(
            title: 'Order Deleted',
            message: 'Order #${order.id} has been deleted successfully',
            id: 'delete_${DateTime.now().millisecondsSinceEpoch}',
          );
        }
      } catch (e) {
        if (mounted) {
          // Show deletion error notification (TOP)
          context.read<NotificationProvider>().addNotification(
            title: 'Deletion Failed',
            message: 'Could not delete order. Please try again.',
            id: 'error_${DateTime.now().millisecondsSinceEpoch}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            icon: const Icon(
              Icons.home,
              color: Colors.black,
              size: 28,
            ),
            tooltip: 'Go to Home',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = orderProvider.orders;

          if (orders.isEmpty) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No orders yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your orders will appear here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(
                  order: order,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                  onDelete: () => _deleteOrder(context, order),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = order.totalPrice;
    final status = order.status;
    final createdAt = order.createdAt;
    final itemCount = order.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Order ID and Delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order #${order.id}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      tooltip: 'Delete Order',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Order details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\$${totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$itemCount item${itemCount != 1 ? 's' : ''}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'pending'
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == 'pending'
                              ? Colors.orange.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                if (createdAt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Ordered on ${createdAt.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}