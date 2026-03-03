// =============================================================================
// GETINLINE FLUTTER - providers/organization_provider.dart
// Organization State Management with Provider
// =============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/organization_model.dart';
import '../models/join_request_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class OrganizationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  OrganizationModel? _currentOrganization;
  List<OrganizationModel> _organizations = [];
  List<JoinRequestModel> _joinRequests = [];
  List<UserModel> _organizationUsers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  OrganizationModel? get currentOrganization => _currentOrganization;
  List<OrganizationModel> get organizations => _organizations;
  List<JoinRequestModel> get joinRequests => _joinRequests;
  List<UserModel> get organizationUsers => _organizationUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrganization => _currentOrganization != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =============================================================================
  // CREATE ORGANIZATION
  // =============================================================================


/// [pic] can be either a [File] (for upload) or a [String] (direct URL).
Future<bool> createOrganization({
  required String organizationName,
  required String mobile,
  required String address,
  String? latlong,
  dynamic pic,          // File or String URL
  required String createdBy, // kept for compatibility, but not sent to backend
}) async {
  _setLoading(true);
  _setError(null);

  try {
    dynamic response;
    final endpoint = ApiConstants.createOrganization;

    if (pic is XFile) {
      // Use multipart upload for file
      response = await _apiService.uploadFile(
        endpoint,
        pic,
        'picUrl', // field name expected by backend (must match 'picUrl' in multer)
        additionalFields: {
          'organizationName': organizationName,
          'mobile': mobile,
          'address': address,
          if (latlong != null) 'latlong': latlong,
          // Do NOT send createdBy/updatedBy/status – backend uses token
        },
      );
    } else {
      // Send as JSON; picUrl may be null or a string URL
      final body = {
        'organizationName': organizationName,
        'mobile': mobile,
        'address': address,
        if (latlong != null) 'latlong': latlong,
        if (pic != null) 'picUrl': pic, // send URL string
      };
      response = await _apiService.post(endpoint, body: body);
    }

    // Backend returns { success: true, data: organization }
    if (response != null && response['data'] != null) {
      _currentOrganization = OrganizationModel.fromJson(response['data']);
      await _dbService.saveOrganizationId(_currentOrganization!.organizationId);
      print('✅ Organization created: ${_currentOrganization!.organizationId}');
      _setLoading(false);
      return true;
    }

    throw ApiException('Failed to create organization: invalid response');
  } on UnauthorizedException catch (e) {
    _setError('Session expired. Please login again.');
    // Optionally trigger logout
  } on ValidationException catch (e) {
    _setError('Validation failed: ${e.message}');
  } on ApiException catch (e) {
    _setError('Organization creation failed: ${e.message}');
  } catch (e) {
    print('❌ Create organization error: $e');
    _setError('Unexpected error: $e');
  } finally {
    _setLoading(false);
  }
  return false;
}


  // Future<bool> createOrganization({
  //   required String organizationName,
  //   required String mobile,
  //   required String address,
  //   String? picUrl,
  //   String? latlong,
  //   required String createdBy,
  // }) async {
  //   _setLoading(true);
  //   _setError(null);

  //   try {
  //     print('🏢 Creating organization: $organizationName');

  //     final response = await _apiService.post(
  //       ApiConstants.createOrganization,
  //       body: {
  //         'organizationName': organizationName,
  //         'mobile': mobile,
  //         'address': address,
  //         'picUrl': picUrl,
  //         'latlong': latlong,
  //         'createdBy': createdBy,
  //         'updatedBy': createdBy,
  //         'status': AppConstants.statusActive,
  //       },
  //     );

  //     if (response != null && response['organization'] != null) {
  //       _currentOrganization = OrganizationModel.fromJson(response['organization']);
  //       await _dbService.saveOrganizationId(_currentOrganization!.organizationId);
        
  //       print('✅ Organization created: ${_currentOrganization!.organizationId}');
  //       _setLoading(false);
  //       return true;
  //     }

  //     throw Exception('Failed to create organization');
  //   } catch (e) {
  //     print('❌ Create organization error: $e');
  //     _setError('Failed to create organization: $e');
  //     _setLoading(false);
  //     return false;
  //   }
  // }


  // =============================================================================
  // CREATE ORGANIZATION
  // =============================================================================

  /// Updates an existing organization.
/// [pic] can be File, String URL, or null to remove the picture.
Future<bool> updateOrganization({
  required String organizationId,
  String? organizationName,
  String? mobile,
  String? address,
  String? latlong,
  dynamic pic,          // File, String URL, or null
}) async {
  _setLoading(true);
  _setError(null);

  try {
    dynamic response;
    final endpoint = '${ApiConstants.createOrganization}/$organizationId';

    if (pic is XFile) {
      // Multipart for file upload
      response = await _apiService.uploadFile(
        endpoint,
        pic,
        'picUrl', // field name expected by backend
        additionalFields: {
          if (organizationName != null) 'organizationName': organizationName,
          if (mobile != null) 'mobile': mobile,
          if (address != null) 'address': address,
          if (latlong != null) 'latlong': latlong,
          // To remove picture, send picUrl = '' (handled below via JSON)
        },
      );
    } else {
      // JSON update; pic can be String URL or null (to remove)
      final Map<String, dynamic> body = {};
      if (organizationName != null) body['organizationName'] = organizationName;
      if (mobile != null) body['mobile'] = mobile;
      if (address != null) body['address'] = address;
      if (latlong != null) body['latlong'] = latlong;
      if (pic != null) {
        body['picUrl'] = pic; // String URL
      } else {
        // Explicitly set picUrl to null to remove the picture
        body['picUrl'] = null;
      }

      response = await _apiService.patch(endpoint, body: body);
    }

    if (response != null && response['data'] != null) {
      _currentOrganization = OrganizationModel.fromJson(response['data']);
      print('✅ Organization updated: $_currentOrganization');
      _setLoading(false);
      return true;
    }

    throw ApiException('Failed to update organization: invalid response');
  } on UnauthorizedException catch (e) {
    _setError('Session expired. Please login again.');
  } on ForbiddenException catch (e) {
    _setError('You do not have permission to update this organization.');
  } on ValidationException catch (e) {
    _setError('Validation failed: ${e.message}');
  } on ApiException catch (e) {
    _setError('Update failed: ${e.message}');
  } catch (e) {
    print('❌ Update organization error: $e');
    _setError('Unexpected error: $e');
  } finally {
    _setLoading(false);
  }
  return false;
}


  // =============================================================================
  // GET ORGANIZATION
  // =============================================================================

  Future<bool> getOrganizationById(String orgId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get('${ApiConstants.getOrganizationById}/$orgId');

      if (response != null && response['data'] != null) {
        _currentOrganization = OrganizationModel.fromJson(response['data']);
        _setLoading(false);
        return true;
      }

      throw Exception('Organization not found');
    } catch (e) {
      print('❌ Get organization error: $e');
      _setError('Failed to load organization: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<OrganizationModel?> getOrganizationByQr(String qrId) async {
    try {
      final response = await _apiService.get('${ApiConstants.getOrgByQr}/$qrId');

      if (response != null && response['organization'] != null) {
        return OrganizationModel.fromJson(response['organization']);
      }
      return null;
    } catch (e) {
      print('❌ Get organization by QR error: $e');
      return null;
    }
  }

  // =============================================================================
  // SEARCH ORGANIZATIONS
  // =============================================================================

  Future<List<OrganizationModel>> searchOrganizations(String query) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        ApiConstants.searchOrganizations,
        queryParams: {'q': query},
      );

      if (response != null && response['organizations'] != null) {
        _organizations = (response['organizations'] as List)
            .map((json) => OrganizationModel.fromJson(json))
            .toList();
        
        _setLoading(false);
        return _organizations;
      }

      _organizations = [];
      _setLoading(false);
      return [];
    } catch (e) {
      print('❌ Search organizations error: $e');
      _setError('Search failed: $e');
      _organizations = [];
      _setLoading(false);
      return [];
    }
  }

  // =============================================================================
  // JOIN REQUEST
  // =============================================================================

  Future<bool> sendJoinRequest({
    required String userId,
    required String organizationId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('📤 Sending join request...');

      await _apiService.post(
        ApiConstants.createJoinRequest,
        body: {
          'userId': userId,
          'organizationId': organizationId,
          'status': AppConstants.requestPending,
        },
      );

      print('✅ Join request sent');
      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ Send join request error: $e');
      _setError('Failed to send join request: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> getJoinRequests(String organizationId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        '${ApiConstants.orgJoinRequests(organizationId)}',
      );

      if (response != null && response['requests'] != null) {
        _joinRequests = (response['requests'] as List)
            .map((json) => JoinRequestModel.fromJson(json))
            .toList();
      } else {
        _joinRequests = [];
      }
      
      _setLoading(false);
    } catch (e) {
      print('❌ Get join requests error: $e');
      _setError('Failed to load join requests: $e');
      _joinRequests = [];
      _setLoading(false);
    }
  }

  Future<bool> acceptJoinRequest({
    required String requestId,
    required String role,
    required String handledBy,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _apiService.post(
        '${ApiConstants.acceptJoinRequest(requestId)}',
        body: {
          'role': role,
          'handledBy': handledBy,
        },
      );

      // Remove from local list
      _joinRequests.removeWhere((r) => r.requestId == requestId);
      
      print('✅ Join request accepted');
      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ Accept join request error: $e');
      _setError('Failed to accept request: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rejectJoinRequest({
    required String requestId,
    required String handledBy,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _apiService.post(
        '${ApiConstants.rejectJoinRequest(requestId)}',
        body: {'handledBy': handledBy},
      );

      // Remove from local list
      _joinRequests.removeWhere((r) => r.requestId == requestId);
      
      print('✅ Join request rejected');
      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ Reject join request error: $e');
      _setError('Failed to reject request: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================================
  // ORGANIZATION USERS
  // =============================================================================

  Future<void> getOrganizationUsers(String organizationId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        '${ApiConstants.getOrganizationUsers(organizationId)}',
      );

      if (response != null && response['users'] != null) {
        _organizationUsers = (response['users'] as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
      } else {
        _organizationUsers = [];
      }
      
      _setLoading(false);
    } catch (e) {
      print('❌ Get organization users error: $e');
      _setError('Failed to load users: $e');
      _organizationUsers = [];
      _setLoading(false);
    }
  }

  Future<bool> updateUserRole({
    required String userId,
    required String role,
    required String updatedBy,
  }) async {
    try {
      await _apiService.patch(
        '${ApiConstants.updateUserRole}/$userId',
        body: {
          'role': role,
          'updatedBy': updatedBy,
        },
      );

      // Update local list
      final index = _organizationUsers.indexWhere((u) => u.uid == userId);
      if (index != -1) {
        _organizationUsers[index] = _organizationUsers[index].copyWith(role: role);
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('❌ Update user role error: $e');
      return false;
    }
  }

  Future<bool> removeUserFromOrganization({
    required String userId,
    required String organizationId,
  }) async {
    try {
      await _apiService.delete(
        '${ApiConstants.removeUserFromOrg(organizationId, userId)}',
      );

      // Remove from local list
      _organizationUsers.removeWhere((u) => u.uid == userId);
      notifyListeners();

      return true;
    } catch (e) {
      print('❌ Remove user error: $e');
      return false;
    }
  }

// =============================================================================
// MISSING: GET MY JOIN REQUESTS (joinRequestRoutes.js)
// =============================================================================
Future<void> getMyJoinRequests() async {
  _setLoading(true);
  try {
    final response = await _apiService.get(ApiConstants.myJoinRequests);
    if (response != null && response['requests'] != null) {
      _joinRequests = (response['requests'] as List)
          .map((json) => JoinRequestModel.fromJson(json)).toList();
      notifyListeners();
    }
  } catch (e) {
    print('❌ Get my join requests error: $e');
  } finally {
    _setLoading(false);
  }
}
  // =============================================================================
  // CLEAR DATA
  // =============================================================================

  void clearOrganizationData() {
    _currentOrganization = null;
    _organizations = [];
    _joinRequests = [];
    _organizationUsers = [];
    notifyListeners();
  }
}
