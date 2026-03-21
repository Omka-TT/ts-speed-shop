import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/Product.dart';
import '../../../providers/cart_provider.dart';

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
      for (int i = 0; i < quantity; i++) {
        await cartProvider.addToCart(widget.product);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("Added to cart successfully"),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add to cart: $e"),
          backgroundColor: Colors.red,
        ),
      );
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

