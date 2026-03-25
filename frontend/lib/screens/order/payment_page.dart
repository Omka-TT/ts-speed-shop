import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Order.dart';
import '../../providers/order_provider.dart';
import '../../constants.dart';
import '../../custom_input_formatters.dart';
import '../../services/notification_service.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  final Order order;

  const PaymentPage({super.key, required this.order});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _paymentSuccessful = false;
  String _selectedMethod = 'card';

  // Form controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  late final FocusNode _cardFocusNode;
  late final FocusNode _cardHolderFocusNode;
  late final FocusNode _expiryFocusNode;
  late final FocusNode _cvvFocusNode;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _cardFocusNode = FocusNode()..addListener(() => setState(() {}));
    _cardHolderFocusNode = FocusNode()..addListener(() => setState(() {}));
    _expiryFocusNode = FocusNode()..addListener(() => setState(() {}));
    _cvvFocusNode = FocusNode()..addListener(() => setState(() {}));

    _cardNumberController.addListener(() => setState(() {}));
    _cardHolderController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
    _cvvController.addListener(() => setState(() {}));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();

    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();

    _cardFocusNode.dispose();
    _cardHolderFocusNode.dispose();
    _expiryFocusNode.dispose();
    _cvvFocusNode.dispose();

    super.dispose();
  }

  bool get _isFormValid {
    // For cash payments, no validation needed
    if (_selectedMethod == 'cash') return true;

    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final cardHolder = _cardHolderController.text.trim();
    final expiry = _expiryController.text;
    final cvv = _cvvController.text;

    // Expiry must be MM/YY format (5 characters including /)
    final expiryValid = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiry);
    final cardValid = cardNumber.length == 16;
    final cvvValid = cvv.length == 3 || cvv.length == 4;
    final cardHolderValid = cardHolder.isNotEmpty && cardHolder.length >= 3;

    return cardValid && cardHolderValid && expiryValid && cvvValid;
  }

  IconData? _getCardBrandIcon() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber.startsWith('4')) {
      return Icons.credit_card;
    } else if (cardNumber.startsWith('5')) {
      return Icons.payment;
    }
    return null;
  }

  Future<void> _confirmPayment() async {
    if (!_isFormValid) {
      if (mounted) {
        await NotificationService.showError(
          context,
          'Please complete all fields correctly (Card: 16 digits, Cardholder: 3+ chars, Expiry: MM/YY, CVV: 3-4 digits)',
          title: 'Invalid Input',
          displayDuration: const Duration(seconds: 3),
        );
      }
      return;
    }

    if (widget.order.status != 'pending') {
      if (mounted) {
        await NotificationService.showError(
          context,
          'Order already paid or not pending.',
          title: 'Payment Error',
          displayDuration: const Duration(seconds: 3),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call payment API
      await context.read<OrderProvider>().payOrder(
            widget.order.id,
            paymentMethod: _selectedMethod,
          );

      // Show success notification (ONLY one notification)
      if (mounted) {
        await NotificationService.showSuccess(
          context,
          'Your order has been paid successfully',
          title: 'Payment Successful',
          displayDuration: const Duration(seconds: 2),
        );
      }

      // Wait before showing success screen
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _paymentSuccessful = true;
        });
      }
    } catch (error) {
      if (mounted) {
        final message = error is Exception
            ? error.toString().replaceFirst('Exception: ', '')
            : 'Payment could not be processed. Please try again.';

        await NotificationService.showError(
          context,
          message,
          title: 'Payment Failed',
          displayDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _backToOrders() {
    // Navigate back to orders/orders list instead of home
    Navigator.of(context).popUntil((route) {
      // Pop until we find the orders route or reach the home screen
      return route.settings.name == '/order' || route.isFirst;
    });

    // If we're not on orders page, try to navigate to it
    if (ModalRoute.of(context)?.settings.name != '/order') {
      Navigator.of(context).pushNamed('/order');
    }
  }

  Widget _paymentMethodOption(String value, String label, IconData icon) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.orange.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: isSelected ? Colors.orange : Colors.grey.shade700),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.orange.shade700 : Colors.black,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.orange.shade700),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentSuccessful) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment Success',
              style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _backToOrders,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 70, color: Colors.green),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Order #${widget.order.id}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _backToOrders,
                  child: const Text('Back to Orders'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${widget.order.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                        'Total: \$${widget.order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor)),
                    const SizedBox(height: 4),
                    Text('Items: ${widget.order.items.length}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _paymentMethodOption('cash', 'Cash (Mock)', Icons.money),
              const SizedBox(height: 24),

              // Only show card details for card payments
             
                const SizedBox(height: 16),
              

              const SizedBox(height: 32),

              // Pay Button with loading state
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: _isLoading ? 0.95 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      onPressed: (_isLoading || !_isFormValid)
                          ? null
                          : _confirmPayment,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Processing Payment...',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            )
                          : Text(
                              'Pay \$${widget.order.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),

              if (!_isFormValid)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please complete all fields correctly',
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
