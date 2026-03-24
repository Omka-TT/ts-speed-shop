import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../screens/cart/cart_screen.dart';
import '../../../providers/cart_provider.dart';
import '../../../screens/order/purchase_history_screen.dart';
import '../../../screens/notifications/notifications_screen.dart';

class QuickActions extends StatefulWidget {
  const QuickActions({super.key});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => AnimationController(
      duration: Duration(milliseconds: 600 + (index * 200)),
      vsync: this,
    ));
    _animations = _controllers.map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    )).toList();

    // Start animations with staggered delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> actions = [
      {
        "icon": "assets/icons/Cart Icon.svg",
        "text": "Cart",
        "press": () => Navigator.pushNamed(context, CartScreen.routeName),
        "showCounter": true,
        "color": const Color(0xFFFFECDF),
        "iconColor": const Color(0xFFFF7643),
      },
      {
        "icon": "assets/icons/receipt.svg",
        "text": "Purchase History",
        "press": () => Navigator.pushNamed(context, PurchaseHistoryScreen.routeName),
        "showCounter": false,
        "color": const Color(0xFFE8F5E8),
        "iconColor": const Color(0xFF4CAF50),
      },
      {
        "icon": "assets/icons/Bell.svg",
        "text": "Notifications",
        "press": () => Navigator.pushNamed(context, NotificationsScreen.routeName),
        "showCounter": false,
        "color": const Color(0xFFE3F2FD),
        "iconColor": const Color(0xFF2196F3),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          actions.length,
          (index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _animations[index].value,
                child: Opacity(
                  opacity: _animations[index].value,
                  child: QuickActionCard(
                    icon: actions[index]["icon"],
                    text: actions[index]["text"],
                    press: actions[index]["press"],
                    showCounter: actions[index]["showCounter"],
                    backgroundColor: actions[index]["color"],
                    iconColor: actions[index]["iconColor"],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
    this.showCounter = false,
    this.backgroundColor = const Color(0xFFFFECDF),
    this.iconColor = const Color(0xFFFF7643),
  }) : super(key: key);

  final String icon, text;
  final GestureTapCallback press;
  final bool showCounter;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: iconColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
                if (showCounter)
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      if (cartProvider.cartItemCount > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 18,
                            width: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4848),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                cartProvider.cartItemCount.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  height: 1,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
