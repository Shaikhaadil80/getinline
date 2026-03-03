// =============================================================================
// GETINLINE FLUTTER - services/database_service.dart
// Local Storage Service using SharedPreferences
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // =============================================================================
  // USER DATA
  // =============================================================================


  // Save First Time User
  Future<bool> saveFirstTimeUser(bool firstTimeUser) async {
    final prefs = await _preferences;
    return await prefs.setBool(StorageKeys.firstTimeUser, firstTimeUser);
  }

  // Get First Time User
  Future<bool?> getFirstTimeUser() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageKeys.firstTimeUser);
  }

  // Save Login Page Name
  Future<bool> saveLoginPageName(String loginPageName) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.loginPageName, loginPageName);
  }

  // Get Login Page Name
  Future<String?> getLoginPageName() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.loginPageName);
  }

  // Save user ID
  Future<bool> saveUserId(String userId) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.userId, userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.userId);
  }
  // Save user UID (Firebase)
  Future<bool> saveUserUid(String uid) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.userUid, uid);
  }

  // Get user UID
  Future<String?> getUserUid() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.userUid);
  }

  // Save user token
  Future<bool> saveUserToken(String token) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.userToken, token);
  }

  // Get user token
  Future<String?> getUserToken() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.userToken);
  }

  // Clear user token
  Future<bool> clearUserToken() async {
    final prefs = await _preferences;
    return await prefs.remove(StorageKeys.userToken);
  }

  // Save FCM token
  Future<bool> saveFcmToken(String token) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.fcmToken, token);
  }

  // Get FCM token
  Future<String?> getFcmToken() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.fcmToken);
  }

  // Save user role
  Future<bool> saveUserRole(String role) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.userRole, role);
  }

  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.userRole);
  }

  // Save organization ID
  Future<bool> saveOrganizationId(String orgId) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.organizationId, orgId);
  }

  // Get organization ID
  Future<String?> getOrganizationId() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.organizationId);
  }

  // Clear organization ID
  Future<bool> clearOrganizationId() async {
    final prefs = await _preferences;
    return await prefs.remove(StorageKeys.organizationId);
  }

  // Save user name
  Future<bool> saveUserName(String name) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.userName, name);
  }

  // Get user name
  Future<String?> getUserName() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.userName);
  }

  // Save user mobile
  Future<bool> saveUserMobile(String mobile) async {
    final prefs = await _preferences;
    return await prefs.setString(StorageKeys.userMobile, mobile);
  }

  // Get user mobile
  Future<String?> getUserMobile() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.userMobile);
  }

  // =============================================================================
  // LOGIN STATE
  // =============================================================================

  // Save login state
  Future<bool> saveLoginState(bool isLoggedIn) async {
    final prefs = await _preferences;
    return await prefs.setBool(StorageKeys.isLoggedIn, isLoggedIn);
  }

  // Get login state
  Future<bool> getLoginState() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // Save remember me
  Future<bool> saveRememberMe(bool remember) async {
    final prefs = await _preferences;
    return await prefs.setBool(StorageKeys.rememberMe, remember);
  }

  // Get remember me
  Future<bool> getRememberMe() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageKeys.rememberMe) ?? false;
  }

  // =============================================================================
  // GENERIC METHODS
  // =============================================================================

  // Save string
  Future<bool> saveString(String key, String value) async {
    final prefs = await _preferences;
    return await prefs.setString(key, value);
  }

  // Get string
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  // Save int
  Future<bool> saveInt(String key, int value) async {
    final prefs = await _preferences;
    return await prefs.setInt(key, value);
  }

  // Get int
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  // Save bool
  Future<bool> saveBool(String key, bool value) async {
    final prefs = await _preferences;
    return await prefs.setBool(key, value);
  }

  // Get bool
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  // Save double
  Future<bool> saveDouble(String key, double value) async {
    final prefs = await _preferences;
    return await prefs.setDouble(key, value);
  }

  // Get double
  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  // Save string list
  Future<bool> saveStringList(String key, List<String> value) async {
    final prefs = await _preferences;
    return await prefs.setStringList(key, value);
  }

  // Get string list
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _preferences;
    return prefs.getStringList(key);
  }

  // Remove key
  Future<bool> remove(String key) async {
    final prefs = await _preferences;
    return await prefs.remove(key);
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }

  // Get all keys
  Future<Set<String>> getAllKeys() async {
    final prefs = await _preferences;
    return prefs.getKeys();
  }

  // =============================================================================
  // CLEAR DATA
  // =============================================================================

  // Clear all user data
  Future<bool> clearUserData() async {
    final prefs = await _preferences;
    
    // Remove all user-related keys
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userUid);
    await prefs.remove(StorageKeys.userToken);
    await prefs.remove(StorageKeys.userRole);
    await prefs.remove(StorageKeys.organizationId);
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.userMobile);
    await prefs.remove(StorageKeys.isLoggedIn);
    
    return true;
  }

  // Clear all data (complete reset)
  Future<bool> clearAll() async {
    final prefs = await _preferences;
    return await prefs.clear();
  }

  // =============================================================================
  // USER SESSION
  // =============================================================================

  // Save complete user session
  Future<bool> saveUserSession({
    required String uid,
    required String token,
    required String role,
    String? organizationId,
    String? name,
    String? mobile,
  }) async {
    try {
      await saveUserUid(uid);
      await saveUserToken(token);
      await saveUserRole(role);
      await saveLoginState(true);
      
      if (organizationId != null) {
        await saveOrganizationId(organizationId);
      }
      if (name != null) {
        await saveUserName(name);
      }
      if (mobile != null) {
        await saveUserMobile(mobile);
      }
      
      return true;
    } catch (e) {
      print('❌ Error saving user session: $e');
      return false;
    }
  }

  // Get user session data
  Future<Map<String, dynamic>> getUserSession() async {
    return {
      'uid': await getUserUid(),
      'token': await getUserToken(),
      'role': await getUserRole(),
      'organizationId': await getOrganizationId(),
      'name': await getUserName(),
      'mobile': await getUserMobile(),
      'isLoggedIn': await getLoginState(),
      'fcmToken': await getFcmToken(),
    };
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final isLoggedIn = await getLoginState();
    final token = await getUserToken();
    final uid = await getUserUid();
    
    return isLoggedIn && token != null && uid != null;
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await clearUserData();
      return true;
    } catch (e) {
      print('❌ Error during logout: $e');
      return false;
    }
  }
}
