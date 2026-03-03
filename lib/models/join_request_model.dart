// =============================================================================
// GETINLINE FLUTTER - models/join_request_model.dart
// Join Request Data Model with Complete Validation
// =============================================================================

class JoinRequestModel {
  final String requestId;
  final String userId;
  final String organizationId;
  final String status;
  final DateTime requestedAt;
  final DateTime? handledAt;
  final String? handledBy;

  JoinRequestModel({
    required this.requestId,
    required this.userId,
    required this.organizationId,
    required this.status,
    required this.requestedAt,
    this.handledAt,
    this.handledBy,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    return JoinRequestModel(
      requestId: json['requestId'] ?? '',
      userId: json['userId'] ?? '',
      organizationId: json['organizationId'] ?? '',
      status: json['status'] ?? 'pending',
      requestedAt: json['requestedAt'] != null 
          ? DateTime.parse(json['requestedAt']) 
          : DateTime.now(),
      handledAt: json['handledAt'] != null 
          ? DateTime.parse(json['handledAt']) 
          : null,
      handledBy: json['handledBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'organizationId': organizationId,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'handledAt': handledAt?.toIso8601String(),
      'handledBy': handledBy,
    };
  }

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isHandled => isAccepted || isRejected;

  @override
  String toString() {
    return 'JoinRequestModel(id: $requestId, status: $status)';
  }
}
