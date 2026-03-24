import 'package:flutter/foundation.dart';
import '../models/Notification.dart';
import 'dart:async';

/// Provider for managing notifications
class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  
  // Stream controller for real-time notification updates
  final _notificationStreamController = StreamController<NotificationModel>.broadcast();

  /// Get all notifications (pinned first)
  List<NotificationModel> get notifications {
    final pinned = _notifications.where((n) => n.isPinned).toList();
    final regular = _notifications.where((n) => !n.isPinned).toList();
    return [...pinned, ...regular];
  }

  /// Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Stream of new notifications
  Stream<NotificationModel> get notificationStream =>
      _notificationStreamController.stream;

  NotificationProvider() {
    _initializePinnedNotifications();
  }

  /// Initialize with 3 default pinned notifications
  void _initializePinnedNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: 'pinned_1',
        title: 'ts-speed channel in TikTok',
        message: 'Check out our TikTok for inspiration and updates 🚀',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isPinned: true,
        isRead: true,
      ),
      NotificationModel(
        id: 'pinned_2',
        title: 'New Features Coming',
        message: 'We are constantly improving your shopping experience',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isPinned: true,
        isRead: true,
      ),
      NotificationModel(
        id: 'pinned_3',
        title: 'Welcome to TS Speed Shop',
        message: 'Enjoy fast and smooth shopping experience',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isPinned: true,
        isRead: true,
      ),
    ]);
  }

  /// Add a new notification
  void addNotification({
    required String title,
    required String message,
    String? id,
    bool isPinned = false,
  }) {
    final notification = NotificationModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
      isPinned: isPinned,
    );

    _notifications.insert(0, notification);
    _notificationStreamController.add(notification);
    notifyListeners();
  }

  /// Mark a notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Get all unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Get all notifications
  List<NotificationModel> getAllNotifications() {
    return List.unmodifiable(notifications);
  }

  /// Delete a notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Clear non-pinned notifications
  void clearNotifications() {
    _notifications.removeWhere((n) => !n.isPinned);
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationStreamController.close();
    super.dispose();
  }
}
