import 'package:flutter/material.dart';
import 'dart:async';
import '../models/Notification.dart';

class TopNotificationWidget extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const TopNotificationWidget({
    super.key,
    required this.notification,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 3),
  });

  @override
  State<TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _fadeController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late Timer _dismissTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // Slide animation from top
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _slideController.forward();
    _fadeController.forward();

    // Auto-dismiss after specified duration
    _dismissTimer = Timer(widget.displayDuration, _dismiss);
  }

  void _dismiss() {
    // Safety check: ensure widget is mounted before accessing state
    if (!mounted || _isDisposed) return;

    // Reverse animations with safety checks
    if (mounted) {
      _slideController.reverse().then((_) {
        if (!mounted || _isDisposed) return;

        _fadeController.reverse().then((_) {
          if (mounted && !_isDisposed) {
            widget.onDismiss?.call();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    // Mark as disposed immediately to prevent any callbacks
    _isDisposed = true;

    // Cancel timer to prevent callback after dispose
    _dismissTimer.cancel();

    // Dispose animation controllers
    _slideController.dispose();
    _fadeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.notification.title.toLowerCase().contains('success') ||
        widget.notification.title.toLowerCase().contains('created');

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              left: BorderSide(
                color: isSuccess ? Colors.green : Colors.orange,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isSuccess ? Colors.green : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.info,
                  color: isSuccess ? Colors.green : Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Close button
              GestureDetector(
                onTap: _dismiss,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade500,
                    size: 20,
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

/// Overlay helper to show top notification
/// Ensures only ONE notification is shown at a time - no duplicates
class TopNotificationOverlay {
  static OverlayEntry? _currentEntry;

  static Future<void> show(
    BuildContext context,
    NotificationModel notification, {
    Duration displayDuration = const Duration(seconds: 3),
  }) async {
    // Remove previous notification if still showing (prevents duplicates)
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: TopNotificationWidget(
          notification: notification,
          displayDuration: displayDuration,
          onDismiss: () {
            _currentEntry?.remove();
            _currentEntry = null;
          },
        ),
      ),
    );

    Overlay.of(context).insert(_currentEntry!);

    // Wait for animation to complete before cleaning up
    await Future.delayed(displayDuration + const Duration(milliseconds: 600));
    
    // Only remove if this entry is still the current one
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (e) {
        // Entry might have already been removed
      }
      _currentEntry = null;
    }
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

