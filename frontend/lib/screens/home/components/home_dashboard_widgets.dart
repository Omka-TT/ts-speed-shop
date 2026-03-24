import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../../screens/cart/cart_screen.dart';
import '../../../providers/cart_provider.dart';
import '../../../screens/order/purchase_history_screen.dart';
import '../../../screens/notifications/notifications_screen.dart';

class HomeDashboardWidgets extends StatefulWidget {
  const HomeDashboardWidgets({super.key});

  @override
  State<HomeDashboardWidgets> createState() => _HomeDashboardWidgetsState();
}

class _HomeDashboardWidgetsState extends State<HomeDashboardWidgets>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<AnimationController> _hoverControllers;
  late List<Animation<double>> _hoverAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => AnimationController(
      duration: Duration(milliseconds: 600 + (index * 150)),
      vsync: this,
    ));
    _animations = _controllers.map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    )).toList();

    _hoverControllers = List.generate(3, (index) => AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    ));
    _hoverAnimations = _hoverControllers.map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
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
    for (var controller in _hoverControllers) {
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
        "gradient": [const Color(0xFFFF6B35), const Color(0xFFFF8F65)],
        "iconColor": Colors.white,
      },
      {
        "icon": "assets/icons/receipt.svg",
        "text": "Purchase History",
        "press": () => Navigator.pushNamed(context, PurchaseHistoryScreen.routeName),
        "showCounter": false,
        "gradient": [const Color(0xFFFF8F65), const Color(0xFFFFB74D)],
        "iconColor": Colors.white,
      },
      {
        "icon": "assets/icons/Bell.svg",
        "text": "Notifications",
        "press": () => Navigator.pushNamed(context, NotificationsScreen.routeName),
        "showCounter": false,
        "gradient": [const Color(0xFFFFB74D), const Color(0xFFFFD54F)],
        "iconColor": Colors.white,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 20),
            Expanded(
              child: AnimatedBuilder(
                animation: _animations[i],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animations[i].value,
                    child: Opacity(
                      opacity: _animations[i].value,
                      child: PremiumDashboardCard(
                        icon: actions[i]["icon"],
                        text: actions[i]["text"],
                        press: actions[i]["press"],
                        showCounter: actions[i]["showCounter"],
                        gradient: actions[i]["gradient"],
                        iconColor: actions[i]["iconColor"],
                        hoverController: _hoverControllers[i],
                        hoverAnimation: _hoverAnimations[i],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PremiumDashboardCard extends StatefulWidget {
  const PremiumDashboardCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
    this.showCounter = false,
    required this.gradient,
    required this.iconColor,
    required this.hoverController,
    required this.hoverAnimation,
  }) : super(key: key);

  final String icon, text;
  final GestureTapCallback press;
  final bool showCounter;
  final List<Color> gradient;
  final Color iconColor;
  final AnimationController hoverController;
  final Animation<double> hoverAnimation;

  @override
  State<PremiumDashboardCard> createState() => _PremiumDashboardCardState();
}

class _PremiumDashboardCardState extends State<PremiumDashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        widget.hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.press,
        child: AnimatedBuilder(
          animation: widget.hoverAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -widget.hoverAnimation.value * 4),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: widget.gradient.map((color) =>
                        color.withOpacity(0.1 + widget.hoverAnimation.value * 0.2)).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: widget.gradient[0].withOpacity(0.3 + widget.hoverAnimation.value * 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.gradient[0].withOpacity(0.15 + widget.hoverAnimation.value * 0.1),
                        blurRadius: 20 + widget.hoverAnimation.value * 10,
                        offset: Offset(0, 8 + widget.hoverAnimation.value * 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1 + widget.hoverAnimation.value * 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1 + widget.hoverAnimation.value * 0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon container with badge
                            Expanded(
                              child: Stack(
                                children: [
                                  // Icon background with gradient
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: widget.gradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.gradient[0].withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        widget.icon,
                                        width: 32,
                                        height: 32,
                                        colorFilter: ColorFilter.mode(widget.iconColor, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                  // Premium notification badge
                                  if (widget.showCounter)
                                    Consumer<CartProvider>(
                                      builder: (context, cartProvider, child) {
                                        if (cartProvider.cartItemCount > 0) {
                                          return Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFFF4848), Color(0xFFFF6B6B)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFFF4848).withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  cartProvider.cartItemCount.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    height: 1,
                                                    fontWeight: FontWeight.w800,
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
                            const SizedBox(height: 16),
                            // Text label with gradient
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.grey.shade800,
                                  Colors.grey.shade600,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Text(
                                widget.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
          },
        ),
      ),
    );
  }
}