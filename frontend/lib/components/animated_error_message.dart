import 'package:flutter/material.dart';

/// An animated error/success message widget that automatically dismisses after 5 seconds.
///
/// Features:
/// - Fade-in animation over 1 second
/// - Display for 5 seconds
/// - Fade-out animation automatically
/// - Supports both error (red) and success (green) messages
/// - Smooth and modern appearance
///
class AnimatedErrorMessage extends StatefulWidget {
  final String message;
  final bool isError;
  final Duration displayDuration;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final VoidCallback? onDismiss;

  const AnimatedErrorMessage({
    Key? key,
    required this.message,
    this.isError = true,
    this.displayDuration = const Duration(seconds: 5),
    this.fadeInDuration = const Duration(seconds: 1),
    this.fadeOutDuration = const Duration(milliseconds: 500),
    this.onDismiss,
  }) : super(key: key);

  @override
  State<AnimatedErrorMessage> createState() => _AnimatedErrorMessageState();
}

class _AnimatedErrorMessageState extends State<AnimatedErrorMessage>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // Fade-in controller
    _fadeInController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn),
    );

    // Fade-out controller
    _fadeOutController = AnimationController(
      duration: widget.fadeOutDuration,
      vsync: this,
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    );

    // Start fade-in animation
    _fadeInController.forward().then((_) {
      // After fade-in completes, wait for display duration then fade out
      Future.delayed(widget.displayDuration, _startFadeOut);
    });
  }

  void _startFadeOut() {
    if (mounted) {
      _fadeOutController.forward().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
          widget.onDismiss?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeInController.isAnimating
          ? _fadeInAnimation
          : _fadeOutAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isError ? Colors.red.shade50 : Colors.green.shade50,
          border: Border.all(
            color: widget.isError ? Colors.red.shade300 : Colors.green.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (widget.isError ? Colors.red : Colors.green)
                  .withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              widget.isError ? Icons.error_outline : Icons.check_circle_outline,
              color: widget.isError ? Colors.red.shade700 : Colors.green.shade700,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message,
                style: TextStyle(
                  color:
                      widget.isError ? Colors.red.shade700 : Colors.green.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    _isVisible = false;
                  });
                  widget.onDismiss?.call();
                }
              },
              child: Icon(
                Icons.close,
                color: widget.isError
                    ? Colors.red.shade400
                    : Colors.green.shade400,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
