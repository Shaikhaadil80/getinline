// =============================================================================
// GETINLINE FLUTTER - models/notification_model.dart
// Notification Data Model with Complete Validation
// =============================================================================

class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.expiresAt,
    this.data,
  });

  // Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'data': data,
    };
  }

  // Copy with method
  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    bool? read,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      data: data ?? this.data,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(read: true);
  }

  // Check if expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if should auto delete (read notifications)
  bool get shouldAutoDelete => read;

  // Get notification type from data
  String? get notificationType {
    return data?['type'] as String?;
  }

  // Get related entity ID from data
  String? get relatedEntityId {
    return data?['entityId'] as String?;
  }

  @override
  String toString() {
    return 'NotificationModel(id: $notificationId, title: $title, read: $read)';
  }
}
