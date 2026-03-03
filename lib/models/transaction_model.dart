// =============================================================================
// GETINLINE FLUTTER - models/transaction_model.dart
// Transaction/Payment Data Model with Complete Validation
// =============================================================================

class TransactionModel {
  final String transactionId;
  final String appointmentId;
  final double amountPaid;
  final String paymentMode;
  final DateTime paymentDate;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  TransactionModel({
    required this.transactionId,
    required this.appointmentId,
    required this.amountPaid,
    required this.paymentMode,
    required this.paymentDate,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'] ?? '',
      paymentDate: json['paymentDate'] != null 
          ? DateTime.parse(json['paymentDate']) 
          : DateTime.now(),
      remarks: json['remarks'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'appointmentId': appointmentId,
      'amountPaid': amountPaid,
      'paymentMode': paymentMode,
      'paymentDate': paymentDate.toIso8601String(),
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  @override
  String toString() {
    return 'TransactionModel(id: $transactionId, amount: $amountPaid, mode: $paymentMode)';
  }
}
