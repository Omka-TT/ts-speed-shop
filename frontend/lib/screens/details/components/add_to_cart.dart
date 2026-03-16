import 'package:flutter/material.dart';
import '../../../models/product.dart';

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

  void addToCart() {
    for (int i = 0; i < quantity; i++) {
      
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.product.title} added to cart"),
      ),
    );
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

