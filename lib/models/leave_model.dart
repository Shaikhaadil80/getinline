// =============================================================================
// GETINLINE FLUTTER - models/leave_model.dart
// Leave Management Data Model with Complete Validation
// =============================================================================

class LeaveModel {
  final String leaveId;
  final String professionalId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveModel({
    required this.leaveId,
    required this.professionalId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      leaveId: json['leaveId'] ?? '',
      professionalId: json['professionalId'] ?? '',
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : DateTime.now(),
      reason: json['reason'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveId': leaveId,
      'professionalId': professionalId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Calculate duration in days
  int get durationInDays => endDate.difference(startDate).inDays + 1;

  // Check if leave is active for a given date
  bool isActiveOn(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
    return dateOnly.isAfter(startOnly.subtract(const Duration(days: 1))) &&
           dateOnly.isBefore(endOnly.add(const Duration(days: 1)));
  }

  @override
  String toString() {
    return 'LeaveModel(id: $leaveId, from: $startDate, to: $endDate)';
  }
}
