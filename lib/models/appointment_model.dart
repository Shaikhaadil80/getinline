// =============================================================================
// GETINLINE FLUTTER - models/appointment_model.dart
// Appointment Data Model with Complete Validation
// =============================================================================

class AppointmentModel {
  final String appointmentId;
  final String name;
  final int age;
  final String mobileNo;
  final String address;
  final String organizationId;
  final String professionalId;
  final DateTime appointmentDate;
  final String appointmentExpectedTime;
  final String status;
  final bool registeredByOrganization;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  AppointmentModel({
    required this.appointmentId,
    required this.name,
    required this.age,
    required this.mobileNo,
    required this.address,
    required this.organizationId,
    required this.professionalId,
    required this.appointmentDate,
    required this.appointmentExpectedTime,
    required this.status,
    required this.registeredByOrganization,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentId: json['appointmentId'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      mobileNo: json['mobileNo'] ?? '',
      address: json['address'] ?? '',
      organizationId: json['organizationId'] ?? '',
      professionalId: json['professionalId'] ?? '',
      appointmentDate: json['appointmentDate'] != null 
          ? DateTime.parse(json['appointmentDate']) 
          : DateTime.now(),
      appointmentExpectedTime: json['appointmentExpectedTime'] ?? '',
      status: json['status'] ?? 'pending',
      registeredByOrganization: json['registeredByOrganization'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'name': name,
      'age': age,
      'mobileNo': mobileNo,
      'address': address,
      'organizationId': organizationId,
      'professionalId': professionalId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentExpectedTime': appointmentExpectedTime,
      'status': status,
      'registeredByOrganization': registeredByOrganization,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  // Status helpers
  bool get isAccepted => status == 'Accepted';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isInLine => status == 'InLine';
  bool get canBeCancelled => !isCancelled && !isCompleted;
  bool get isCompleted => false; // Would need additional field

  @override
  String toString() {
    return 'AppointmentModel(id: $appointmentId, name: $name, date: $appointmentDate, status: $status)';
  }
}
