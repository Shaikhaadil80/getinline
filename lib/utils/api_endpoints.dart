// =============================================================================
// GETINLINE FLUTTER - utils/api_endpoints.dart
// Centralized API Endpoint Configuration
// =============================================================================

import 'environment_config.dart';

class ApiEndpoints {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  // User Endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static const String updateProfile = '/users/profile';
  static const String updatePassword = '/users/password';
  
  // Organization Endpoints
  static const String organizations = '/organizations';
  static String organizationById(String id) => '/organizations/$id';
  static String organizationByQr(String qr) => '/organizations/qr/$qr';
  static const String createOrganization = '/organizations';
  static const String searchOrganizations = '/organizations/search';
  static String organizationUsers(String orgId) => '/organizations/$orgId/users';
  static String updateUserRole = '/organizations/users/role';
  static String removeUser = '/organizations/users/remove';
  
  // Join Request Endpoints
  static const String joinRequests = '/join-requests';
  static String joinRequestsByOrg(String orgId) => '/join-requests/organization/$orgId';
  static String acceptJoinRequest(String id) => '/join-requests/$id/accept';
  static String rejectJoinRequest(String id) => '/join-requests/$id/reject';
  
  // Professional Endpoints
  static const String professionals = '/professionals';
  static String professionalById(String id) => '/professionals/$id';
  static String professionalsByOrg(String orgId) => '/professionals/organization/$orgId';
  static String professionalByQr(String qr) => '/professionals/qr/$qr';
  static String updateProfessionalStatus(String id) => '/professionals/$id/status';
  
  // Leave Endpoints
  static const String leaves = '/leaves';
  static String leavesByProfessional(String profId) => '/leaves/professional/$profId';
  static String deleteLeave(String id) => '/leaves/$id';
  static String checkLeaveAvailability = '/leaves/check-availability';
  
  // Appointment Endpoints
  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';
  static String appointmentsByUser(String userId) => '/appointments/user/$userId';
  static String appointmentsByOrg(String orgId) => '/appointments/organization/$orgId';
  static String appointmentsByProfessional(String profId) => '/appointments/professional/$profId';
  static String appointmentQueue = '/appointments/queue';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';
  static const String checkAppointmentLimit = '/appointments/check-limit';
  
  // Transaction Endpoints
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';
  static String transactionsByAppointment(String aptId) => '/transactions/appointment/$aptId';
  
  // Notification Endpoints
  static const String notifications = '/notifications';
  static String notificationsByUser(String userId) => '/notifications/user/$userId';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static String deleteNotification(String id) => '/notifications/$id';
  
  // Notify Me Endpoints
  static const String notifyMe = '/notify';
  static String notifyByUser(String userId) => '/notify/user/$userId';
  
  // FCM Token Endpoints
  static const String updateFcmToken = '/users/fcm-token';
  
  // Analytics Endpoints
  static const String analytics = '/analytics';
  static String analyticsOrganization(String orgId) => '/analytics/organization/$orgId';
  static String analyticsProfessional(String profId) => '/analytics/professional/$profId';
  
  // Export Endpoints
  static const String exportAppointments = '/export/appointments';
  static const String exportTransactions = '/export/transactions';
  static const String exportUsers = '/export/users';
  
  // Build complete URL
  static String buildUrl(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString()))).toString();
    }
    return uri.toString();
  }
}
