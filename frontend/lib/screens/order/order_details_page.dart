import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Order.dart';
import '../../models/Product.dart';
import '../../constants.dart';
import 'payment_page.dart';

class OrderDetailsPage extends StatefulWidget {
  static String routeName = "/order-details";

  final Order order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isPayButtonPressed = false;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderItems = order.items;
    final totalPrice = order.totalPrice;
    final status = order.status;
    final createdAt = order.createdAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order #${order.id}",
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: status == 'pending'
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: status == 'pending'
                        ? Colors.orange.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      status == 'pending' ? Icons.schedule : Icons.check_circle,
                      color: status == 'pending'
                          ? Colors.orange.shade600
                          : Colors.green.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status == 'pending' ? "Order Pending" : "Order Completed",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: status == 'pending'
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Order #${order.id}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: status == 'pending'
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Placed on ${createdAt.toLocal().toString().split(' ')[0]}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: status == 'pending'
                                  ? Colors.orange.shade600
                                  : Colors.green.shade600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Order Items
              Text(
                "Order Items",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              ...orderItems.map((item) {
                final product = item.product;
                final quantity = item.quantity;
                final price = item.price;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: product.images.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(product.images[0]),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey.shade200,
                        ),
                        child: product.images.isEmpty
                            ? const Icon(Icons.image, color: Colors.grey)
                            : null,
                      ),

                      const SizedBox(width: 16),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Quantity: $quantity",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Status",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'pending'
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: totalPrice),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) {
                            return Text(
                              "\$${value.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: status == 'pending'
          ? SafeArea(
              minimum: const EdgeInsets.all(12),
              child: AnimatedScale(
                scale: _isPayButtonPressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isPayButtonPressed = true),
                  onTapUp: (_) => setState(() => _isPayButtonPressed = false),
                  onTapCancel: () =>
                      setState(() => _isPayButtonPressed = false),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(order: order),
                        ),
                      );
                    },
                    child: const Text(
                      "Pay Now",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
