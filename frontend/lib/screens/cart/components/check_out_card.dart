import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/Notification.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../screens/init_screen.dart';
import '../../../helper/utils.dart';
import '../../../components/top_notification_widget.dart';

class CheckoutCard extends StatefulWidget {
  const CheckoutCard({
    Key? key,
  }) : super(key: key);

  @override
  State<CheckoutCard> createState() => _CheckoutCardState();
}

class _CheckoutCardState extends State<CheckoutCard> {
  double _previousTotal = 0.0;
  double _currentTotal = 0.0;

  Future<void> _createOrder(BuildContext context, OrderProvider orderProvider, CartProvider cartProvider) async {
    try {
      // Create the order
      await orderProvider.createOrder();

      // Clear the cart after successful order creation
      await cartProvider.fetchCartItems();

      // Add order created notification
      final notificationProvider = context.read<NotificationProvider>();
      final notification = NotificationModel(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Order Created',
        message: 'Your order has been successfully created',
        createdAt: DateTime.now(),
      );
      notificationProvider.addNotification(
        title: notification.title,
        message: notification.message,
        id: notification.id,
      );

      // Show top notification overlay
      if (mounted) {
        await TopNotificationOverlay.show(context, notification, displayDuration: const Duration(seconds: 2));
      }

      // Switch to OrderPage tab (index 2) after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        final initScreenState = context.findAncestorStateOfType<InitScreenState>();
        initScreenState?.updateCurrentIndex(2);
      }
    } catch (e) {
      if (mounted) {
        // Show error notification (TOP)
        context.read<NotificationProvider>().addNotification(
          title: 'Order Creation Failed',
          message: 'Could not create order. Please try again.',
          id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      // height: 174,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -15),
            blurRadius: 20,
            color: const Color(0xFFDADADA).withOpacity(0.15),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                double total = 0;
                for (var item in cartProvider.cartItems) {
                  // Safe price parsing: handle String or num from backend
                  final price = parsePrice(item['product']['price']);
                  
                  final qty = (item['quantity'] ?? 1) as int;
                  
                  // Debug log
                  print('[CheckoutCard] Price: $price (type: ${price.runtimeType}), Qty: $qty');
                  
                  total += (price * qty);
                }

                // Update totals for animation
                if (_currentTotal != total) {
                  _previousTotal = _currentTotal;
                  _currentTotal = total;
                }

                return Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: _previousTotal, end: _currentTotal),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Text.rich(
                            TextSpan(
                              text: "Total:\n",
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                  text: "\$${value.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: cartProvider.cartItems.isEmpty
                            ? null
                            : () {
                                // Get providers synchronously
                                final orderProvider = context.read<OrderProvider>();
                                
                                // Perform async operation
                                _createOrder(context, orderProvider, cartProvider);
                              },
                        child: const Text(
                          "Pay",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

