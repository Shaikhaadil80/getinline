// =============================================================================
// GETINLINE FLUTTER - models/notify_model.dart
// Notify Model for Professional Availability Alerts
// =============================================================================

class NotifyModel {
  final String notifyId;
  final String userId;
  final String professionalId;
  final String organizationId;
  final DateTime createdAt;

  NotifyModel({
    required this.notifyId,
    required this.userId,
    required this.professionalId,
    required this.organizationId,
    required this.createdAt,
  });

  // Create from JSON
  factory NotifyModel.fromJson(Map<String, dynamic> json) {
    return NotifyModel(
      notifyId: json['notifyId'] ?? '',
      userId: json['userId'] ?? '',
      professionalId: json['professionalId'] ?? '',
      organizationId: json['organizationId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'notifyId': notifyId,
      'userId': userId,
      'professionalId': professionalId,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with method
  NotifyModel copyWith({
    String? notifyId,
    String? userId,
    String? professionalId,
    String? organizationId,
    DateTime? createdAt,
  }) {
    return NotifyModel(
      notifyId: notifyId ?? this.notifyId,
      userId: userId ?? this.userId,
      professionalId: professionalId ?? this.professionalId,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotifyModel(id: $notifyId, userId: $userId, professionalId: $professionalId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotifyModel &&
        other.notifyId == notifyId &&
        other.userId == userId &&
        other.professionalId == professionalId &&
        other.organizationId == organizationId;
  }

  @override
  int get hashCode {
    return notifyId.hashCode ^
        userId.hashCode ^
        professionalId.hashCode ^
        organizationId.hashCode;
  }
}
