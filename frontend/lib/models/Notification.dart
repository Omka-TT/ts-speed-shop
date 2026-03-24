class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;
  final bool isPinned;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.isPinned = false,
  });

  /// Create a copy of this notification with modified fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    bool? isPinned,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isPinned': isPinned,
    };
  }

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      isPinned: json['isPinned'] ?? false,
    );
  }

  @override
  String toString() =>
      'NotificationModel(id: $id, title: $title, isRead: $isRead, isPinned: $isPinned)';
}
