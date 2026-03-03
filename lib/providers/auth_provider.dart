// =============================================================================
// GETINLINE FLUTTER - providers/auth_provider.dart
// Authentication State Management with Provider
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  User? get firebaseCurrentUser => FirebaseAuth.instance.currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;
  bool get isProfileCreated => _currentUser != null;
  bool get hasOrganization => _currentUser?.hasOrganization ?? false;
  String? get userRole => _currentUser?.role;
  String? get organizationId => _currentUser?.organizationId;

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =============================================================================
  // LOGIN
  // =============================================================================

  Future<bool> handleLogin(String uid) async {
    _setLoading(true);
    _setError(null);

    try {
      print('🔐 Handling login for UID: $uid');

      // Get token
      final token = await _authService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Failed to get authentication token');
      }

      // Check if user exists in database
      final response = await _apiService.get('${ApiConstants.getUserByUid}/$uid');
      
      if (response != null && response['data'] != null) {
        // User exists, load user data
        _currentUser = UserModel.fromJson(response['data']);
        
        // Save session
        await _dbService.saveUserSession(
          uid: uid,
          token: token,
          role: _currentUser!.role,
          organizationId: _currentUser!.organizationId,
          name: _currentUser!.name,
          mobile: _currentUser!.mobile,
        );
        
        print('✅ User loaded successfully');
        _setLoading(false);
        return true;
      } else {
        // User doesn't exist, needs to create profile
        print('⚠️ User not found in database');
        await _dbService.saveUserUid(uid);
        await _dbService.saveUserToken(token);
        _setLoading(false);
        return false; // Indicates profile creation needed
      }
    } catch (e) {
      print('❌ Login error: $e');
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================================
  // CREATE/UPDATE PROFILE
  // =============================================================================

  Future<bool> createProfile({
    required String uid,
    required String name,
    required String mobile,
    required String address,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('📝 Creating user profile...');

      final response = await _apiService.post(
        ApiConstants.createUser,
        body: {
          'uid': uid,
          'name': name,
          'mobile': mobile,
          'address': address,
          'role': role,
          'status': AppConstants.statusActive,
          'createdBy': uid,
          'updatedBy': uid,
        },
      );

      if (response != null && response['data'] != null) {
        _currentUser = UserModel.fromJson(response['data']);
        
        // Save session
        final token = await _authService.getCurrentUserToken();
        await _dbService.saveUserSession(
          uid: uid,
          token: token!,
          role: role,
          name: name,
          mobile: mobile,
        );
        
        print('✅ Profile created successfully');
        _setLoading(false);
        return true;
      }

      throw Exception('Failed to create profile');
    } catch (e) {
      print('❌ Create profile error: $e');
      _setError('Failed to create profile: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String mobile,
    required String address,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      print('📝 Updating user profile...');

      final response = await _apiService.put(
        '${ApiConstants.updateProfile}/${_currentUser!.uid}',
        body: {
          'name': name,
          'mobile': mobile,
          'address': address,
          'updatedBy': _currentUser!.uid,
        },
      );

      if (response != null && response['data'] != null) {
        _currentUser = UserModel.fromJson(response['data']);
        
        // Update local storage
        await _dbService.saveUserName(name);
        await _dbService.saveUserMobile(mobile);
        
        print('✅ Profile updated successfully');
        _setLoading(false);
        return true;
      }

      throw Exception('Failed to update profile');
    } catch (e) {
      print('❌ Update profile error: $e');
      _setError('Failed to update profile: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================================
  // LOGOUT
  // =============================================================================

  Future<void> logout() async {
    _setLoading(true);

    try {
      print('🔐 Logging out...');
      
      await _authService.signOut();
      await _dbService.logout();
      
      _currentUser = null;
      
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // =============================================================================
  // REFRESH USER DATA
  // =============================================================================

  Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    try {
      final response = await _apiService.get(
        '${ApiConstants.getUserByUid}/${_currentUser!.uid}',
      );

      if (response != null && response['data'] != null) {
        _currentUser = UserModel.fromJson(response['data']);
        notifyListeners();
        print('✅ User data refreshed');
      }
    } catch (e) {
      print('❌ Refresh user data error: $e');
    }
  }

  // =============================================================================
  // CHECK AUTH STATUS
  // =============================================================================

  Future<bool> checkAuthStatus() async {
    try {
      final isLoggedIn = await _dbService.isUserLoggedIn();
      
      if (!isLoggedIn) {
        return false;
      }

      final uid = await _dbService.getUserUid();
      if (uid == null) {
        return false;
      }

      // Try to load user data
      return await handleLogin(uid);
    } catch (e) {
      print('❌ Check auth status error: $e');
      return false;
    }
  }

  // =============================================================================
  // ORGANIZATION UPDATES
  // =============================================================================

  void updateOrganizationId(String? orgId) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(organizationId: orgId);
      if (orgId != null) {
        _dbService.saveOrganizationId(orgId);
      } else {
        _dbService.clearOrganizationId();
      }
      notifyListeners();
    }
  }

  void updateUserRole(String role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      _dbService.saveUserRole(role);
      notifyListeners();
    }
  }

  // =============================================================================
// MISSING: GET ALL USERS (Admin Only) (userRoutes.js)
// =============================================================================
Future<List<UserModel>> getAllUsers() async {
  try {
    final response = await _apiService.get(ApiConstants.users);
    if (response != null && response['users'] != null) {
      return (response['users'] as List)
          .map((json) => UserModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('❌ Get all users error: $e');
    return [];
  }
}

// =============================================================================
// MISSING: UPDATE FCM TOKEN (userRoutes.js)
// =============================================================================
Future<void> updateFcmToken(String fcmToken) async {
  try {
    await _apiService.patch(
      ApiConstants.updateFcmToken,
      body: {'fcmToken': fcmToken},
    );
    print('✅ FCM Token updated');
  } catch (e) {
    print('❌ Update FCM Token error: $e');
  }
}

// =============================================================================
// MISSING: UPDATE USER ROLE BY UID (Admin/Manager) (userRoutes.js)
// =============================================================================
Future<bool> updateUserRoleByUid(String targetUid, String role) async {
  try {
    await _apiService.patch(
      ApiConstants.updateRoleByUid(targetUid),
      body: {'role': role},
    );
    return true;
  } catch (e) {
    print('❌ Update user role error: $e');
    return false;
  }
}

// =============================================================================
// MISSING: UPDATE USER STATUS (Admin) (userRoutes.js)
// =============================================================================
Future<bool> updateUserStatus(String targetUid, String status) async {
  try {
    await _apiService.patch(
      ApiConstants.updateUserStatus,
      body: {'uid': targetUid, 'status': status}, // Assuming backend expects uid in body here
    );
    return true;
  } catch (e) {
    return false;
  }
}
}
