import 'package:flutter/material.dart';
import '../models/Notification.dart';
import '../components/top_notification_widget.dart';

/// Centralized notification service for displaying notifications consistently across the app.
/// Ensures only one notification is shown at a time, prevents duplicates, and handles
/// all notification lifecycle properly.
///
/// Usage:
///   - Success: NotificationService.showSuccess(context, "Success message")
///   - Error: NotificationService.showError(context, "Error message")
///   - Info: NotificationService.showInfo(context, "Info message")
///   - Dismiss: NotificationService.dismiss()
class NotificationService {
  NotificationService._();

  /// Show a success notification (green styling, success icon)
  static Future<void> showSuccess(
    BuildContext context,
    String message, {
    String title = 'Success',
    Duration displayDuration = const Duration(seconds: 3),
  }) async {
    final notification = NotificationModel(
      id: 'success_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );

    if (context.mounted) {
      await TopNotificationOverlay.show(
        context,
        notification,
        displayDuration: displayDuration,
      );
    }
  }

  /// Show an error notification (orange styling, error icon)
  static Future<void> showError(
    BuildContext context,
    String message, {
    String title = 'Error',
    Duration displayDuration = const Duration(seconds: 4),
  }) async {
    final notification = NotificationModel(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );

    if (context.mounted) {
      await TopNotificationOverlay.show(
        context,
        notification,
        displayDuration: displayDuration,
      );
    }
  }

  /// Show an info notification (info icon)
  static Future<void> showInfo(
    BuildContext context,
    String message, {
    String title = 'Info',
    Duration displayDuration = const Duration(seconds: 3),
  }) async {
    final notification = NotificationModel(
      id: 'info_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );

    if (context.mounted) {
      await TopNotificationOverlay.show(
        context,
        notification,
        displayDuration: displayDuration,
      );
    }
  }

  /// Show a custom notification
  static Future<void> show(
    BuildContext context,
    NotificationModel notification, {
    Duration displayDuration = const Duration(seconds: 3),
  }) async {
    if (context.mounted) {
      await TopNotificationOverlay.show(
        context,
        notification,
        displayDuration: displayDuration,
      );
    }
  }

  /// Dismiss any currently showing notification
  static void dismiss() {
    TopNotificationOverlay.dismiss();
  }
}
