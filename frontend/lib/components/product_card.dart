import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/Product.dart';
import '../screens/product.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    this.width,
    this.aspectRatio = 0.86,
    required this.product,
  }) : super(key: key);

  final double? width;
  final double aspectRatio;
  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;
  bool _isHovered = false;
  bool _buyPressed = false;

  void _onTapDown(_) => setState(() => _isPressed = true);
  void _onTapUp(_) => setState(() => _isPressed = false);
  void _onTapCancel() => setState(() => _isPressed = false);

  void _onBuyDown(TapDownDetails _) => setState(() => _buyPressed = true);
  void _onBuyUp(TapUpDetails _) => setState(() => _buyPressed = false);
  void _onBuyCancel() => setState(() => _buyPressed = false);

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductPage(product: widget.product)),
    );
  }

  Widget _buildImage() {
    final imagePath = widget.product.primaryImage;

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final boxShadow = [
      BoxShadow(
        color: Colors.black.withAlpha(_isHovered ? 30 : 22),
        blurRadius: _isHovered ? 18 : 12,
        offset: const Offset(0, 8),
      ),
    ];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _navigateToDetails,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: boxShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    Hero(
                      tag: 'product-image-${widget.product.id}',
                      child: _buildImage(),
                    ),

                    // Gradient overlay (dark -> transparent at top)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withAlpha((0.54 * 255).round()),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6],
                          ),
                        ),
                      ),
                    ),

                    // Bottom content: title + price + buy button
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '\$${widget.product.price.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Buy button overlay
                          GestureDetector(
                            onTapDown: _onBuyDown,
                            onTapUp: _onBuyUp,
                            onTapCancel: _onBuyCancel,
                            onTap: () {
                              // quick scale effect handled by state; then navigate
                              setState(() => _buyPressed = false);
                              _navigateToDetails();
                            },
                            child: AnimatedScale(
                              scale: _buyPressed ? 0.93 : 1.0,
                              duration: const Duration(milliseconds: 90),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(30),
                                      blurRadius: 8,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Buy',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
    
