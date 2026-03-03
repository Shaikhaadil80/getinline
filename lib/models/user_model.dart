// =============================================================================
// GETINLINE FLUTTER - models/user_model.dart
// User Data Model with Complete Validation
// =============================================================================

class UserModel {
  final String uid;
  final String name;
  final String mobile;
  final String address;
  final String role;
  final String? organizationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final String status;
  final String? remark;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.mobile,
    required this.address,
    required this.role,
    this.organizationId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.status,
    this.remark,
    this.fcmToken,
  });

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'customer',
      organizationId: json['organizationId'],
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
      fcmToken: json['fcmToken'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'mobile': mobile,
      'address': address,
      'role': role,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'status': status,
      'remark': remark,
      'fcmToken': fcmToken,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? name,
    String? mobile,
    String? address,
    String? role,
    String? organizationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? status,
    String? remark,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Check if user is in an organization
  bool get hasOrganization => organizationId != null && organizationId!.isNotEmpty;

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Check if user is manager
  bool get isManager => role == 'manager';

  // Check if user is receptionist
  bool get isReceptionist => role == 'receptionist';

  // Check if user is customer
  bool get isCustomer => role == 'customer';

  // Check if user is professional
  bool get isProfessional => role == 'professional';

  // Check if user has organization role
  bool get hasOrganizationRole => isAdmin || isManager || isReceptionist || isProfessional;

  // Check if user is active
  bool get isActive => status == 'active';

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, role: $role, organizationId: $organizationId)';
  }
}
