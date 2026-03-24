import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/Product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/notification_provider.dart';

class AddToCart extends StatefulWidget {
  final Product product;

  const AddToCart({
    super.key,
    required this.product,
  });

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  int quantity = 1;

  void increase() {
    setState(() {
      quantity++;
    });
  }

  void decrease() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void addToCart() async {
    try {
      final cartProvider = context.read<CartProvider>();
      await cartProvider.addToCart(widget.product, quantity: quantity);

      // Show success notification (TOP)
      if (mounted) {
        context.read<NotificationProvider>().addNotification(
          title: 'Added to Cart',
          message: 'Added $quantity ${quantity == 1 ? 'item' : 'items'} to cart successfully',
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } catch (e) {
      // Show error notification (TOP)
      if (mounted) {
        context.read<NotificationProvider>().addNotification(
          title: 'Cart Error',
          message: 'Could not add to cart. Please try again.',
          id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            IconButton(
              onPressed: decrease,
              icon: const Icon(Icons.remove),
            ),

            Text(
              quantity.toString(),
              style: const TextStyle(fontSize: 18),
            ),

            IconButton(
              onPressed: increase,
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: addToCart,
            child: const Text("Add To Cart"),
          ),
        )
      ],
    );
  }
}

