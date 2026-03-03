// =============================================================================
// GETINLINE FLUTTER - models/professional_model.dart  
// Professional Data Model with TimeSlots and Complete Validation
// =============================================================================

class TimeSlot {
  final String fromTime;
  final String toTime;

  TimeSlot({
    required this.fromTime,
    required this.toTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromTime': fromTime,
      'toTime': toTime,
    };
  }

  @override
  String toString() => '$fromTime - $toTime';
}

class ProfessionalModel {
  final String professionalId;
  final String name;
  final String profession;
  final String degree;
  final String mobile;
  final String status; // IN or OUT
  final List<TimeSlot> slots;
  final List<String> commonLeaves;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final bool active;
  final String? remark;
  final String organizationId;
  final bool isPaidAppointment;
  final double appointmentFees;
  final double minBookAppointmentFees;
  final int commonMeetingTimeFrame;
  final String qrId;
  final String? inOutNote;

  ProfessionalModel({
    required this.professionalId,
    required this.name,
    required this.profession,
    required this.degree,
    required this.mobile,
    required this.status,
    required this.slots,
    required this.commonLeaves,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.active,
    this.remark,
    required this.organizationId,
    required this.isPaidAppointment,
    required this.appointmentFees,
    required this.minBookAppointmentFees,
    required this.commonMeetingTimeFrame,
    required this.qrId,
    this.inOutNote,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      professionalId: json['professionalId'] ?? '',
      name: json['name'] ?? '',
      profession: json['profession'] ?? '',
      degree: json['degree'] ?? '',
      mobile: json['mobile'] ?? '',
      status: json['status'] ?? 'OUT',
      slots: (json['slots'] as List?)
          ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      commonLeaves: List<String>.from(json['commonLeaves'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      active: json['active'] ?? true,
      remark: json['remark'],
      organizationId: json['organizationId'] ?? '',
      isPaidAppointment: json['isPaidAppointment'] ?? false,
      appointmentFees: (json['appointmentFees'] ?? 0).toDouble(),
      minBookAppointmentFees: (json['minBookAppointmentFees'] ?? 0).toDouble(),
      commonMeetingTimeFrame: json['commonMeetingTimeFrame'] ?? 15,
      qrId: json['qrId'] ?? '',
      inOutNote: json['inOutNote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'professionalId': professionalId,
      'name': name,
      'profession': profession,
      'degree': degree,
      'mobile': mobile,
      'status': status,
      'slots': slots.map((e) => e.toJson()).toList(),
      'commonLeaves': commonLeaves,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'active': active,
      'remark': remark,
      'organizationId': organizationId,
      'isPaidAppointment': isPaidAppointment,
      'appointmentFees': appointmentFees,
      'minBookAppointmentFees': minBookAppointmentFees,
      'commonMeetingTimeFrame': commonMeetingTimeFrame,
      'qrId': qrId,
      'inOutNote': inOutNote,
    };
  }

  // Helper getters
  bool get isIn => status == 'IN';
  bool get isOut => status == 'OUT';
  bool get isAvailable => isIn && active;
  bool get requiresPayment => isPaidAppointment;
  bool get hasSlots => slots.isNotEmpty;

  @override
  String toString() {
    return 'ProfessionalModel(id: $professionalId, name: $name, status: $status)';
  }
}
