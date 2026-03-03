// =============================================================================
// GETINLINE FLUTTER - models/organization_model.dart
// Organization Data Model with Complete Validation
// =============================================================================

class OrganizationModel {
  final String organizationId;
  final String organizationName;
  final String? picUrl;
  final String mobile;
  final String address;
  final String? latlong;
  final String qrId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final String status;
  final String? remark;

  OrganizationModel({
    required this.organizationId,
    required this.organizationName,
    this.picUrl,
    required this.mobile,
    required this.address,
    this.latlong,
    required this.qrId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.status,
    this.remark,
  });

  // Create from JSON
  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      organizationId: json['organizationId'] ?? '',
      organizationName: json['organizationName'] ?? '',
      picUrl: json['picUrl'],
      mobile: json['mobile'] ?? '',
      address: json['address'] ?? '',
      latlong: json['latlong'],
      qrId: json['qrId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      status: json['status'] ?? 'active',
      remark: json['remark'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'picUrl': picUrl,
      'mobile': mobile,
      'address': address,
      'latlong': latlong,
      'qrId': qrId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'status': status,
      'remark': remark,
    };
  }

  // Copy with method
  OrganizationModel copyWith({
    String? organizationId,
    String? organizationName,
    String? picUrl,
    String? mobile,
    String? address,
    String? latlong,
    String? qrId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? status,
    String? remark,
  }) {
    return OrganizationModel(
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      picUrl: picUrl ?? this.picUrl,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      latlong: latlong ?? this.latlong,
      qrId: qrId ?? this.qrId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      status: status ?? this.status,
      remark: remark ?? this.remark,
    );
  }

  // Check if organization is active
  bool get isActive => status == 'active';

  // Check if has profile picture
  bool get hasPicture => picUrl != null && picUrl!.isNotEmpty;

  // Check if has location
  bool get hasLocation => latlong != null && latlong!.isNotEmpty;

  @override
  String toString() {
    return 'OrganizationModel(id: $organizationId, name: $organizationName, qrId: $qrId)';
  }
}
