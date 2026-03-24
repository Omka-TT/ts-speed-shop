import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../models/Cart.dart';
import '../../../providers/cart_provider.dart';

class CartCard extends StatefulWidget {
  const CartCard({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> with TickerProviderStateMixin {
  bool _isDecreasePressed = false;
  bool _isIncreasePressed = false;

  void _onDecreaseTapDown() {
    setState(() => _isDecreasePressed = true);
  }

  void _onDecreaseTapUp() {
    setState(() => _isDecreasePressed = false);
  }

  void _onIncreaseTapDown() {
    setState(() => _isIncreasePressed = true);
  }

  void _onIncreaseTapUp() {
    setState(() => _isIncreasePressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: AspectRatio(
              aspectRatio: 0.88,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(widget.cart.product.images[0]),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cart.product.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${(widget.cart.product.price * widget.cart.numOfItem).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFFFF7643),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Decrease button
                    GestureDetector(
                      onTapDown: (_) => _onDecreaseTapDown(),
                      onTapUp: (_) => _onDecreaseTapUp(),
                      onTapCancel: () => _onDecreaseTapUp(),
                      child: AnimatedScale(
                        scale: _isDecreasePressed ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final cartProvider = context.read<CartProvider>();
                              final cartItemId = cartProvider.cartItems
                                  .firstWhere(
                                    (item) => item['product']['id'] == widget.cart.product.id,
                                    orElse: () => {'id': null},
                                  )['id'];
                              if (cartItemId != null) {
                                await cartProvider.decreaseQuantity(cartItemId);
                              }
                            },
                            icon: const Icon(Icons.remove, size: 16),
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Quantity display with animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        "x${widget.cart.numOfItem}",
                        key: ValueKey<int>(widget.cart.numOfItem),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Increase button
                    GestureDetector(
                      onTapDown: (_) => _onIncreaseTapDown(),
                      onTapUp: (_) => _onIncreaseTapUp(),
                      onTapCancel: () => _onIncreaseTapUp(),
                      child: AnimatedScale(
                        scale: _isIncreasePressed ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final cartProvider = context.read<CartProvider>();
                              final cartItemId = cartProvider.cartItems
                                  .firstWhere(
                                    (item) => item['product']['id'] == widget.cart.product.id,
                                    orElse: () => {'id': null},
                                  )['id'];
                              if (cartItemId != null) {
                                await cartProvider.increaseQuantity(cartItemId);
                              }
                            },
                            icon: const Icon(Icons.add, size: 16),
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) => IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: () => _showRemoveDialog(context, cartProvider),
              tooltip: "Remove item",
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text("Remove this item from cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Find the cart item id from cart.product.id
              final cartItemId = cartProvider.cartItems
                  .firstWhere(
                    (item) => item['product']['id'] == widget.cart.product.id,
                    orElse: () => {'id': null},
                  )['id'];
              if (cartItemId != null) {
                cartProvider.removeFromCart(cartItemId);
              }
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
