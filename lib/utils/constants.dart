// =============================================================================
// GETINLINE FLUTTER - utils/constants.dart
// Application Constants, Colors, API Endpoints, and Validation Rules
// =============================================================================

import 'package:flutter/material.dart';

// =============================================================================
// APP COLORS
// =============================================================================

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color accent = Color(0xFFFF9800);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Professional Status Colors
  static const Color inStatus = Color(0xFF4CAF50);
  static const Color outStatus = Color(0xFFF44336);
  
  // Appointment Status Colors
  static const Color acceptedStatus = Color(0xFF4CAF50);
  static const Color pendingStatus = Color(0xFFFF9800);
  static const Color cancelledStatus = Color(0xFFF44336);
  static const Color inLineStatus = Color(0xFF2196F3);
  
  // Additional Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x29000000);
}

// =============================================================================
// API CONSTANTS
// =============================================================================

class ApiConstants {
  // Base URL - UPDATE THIS WITH YOUR BACKEND URL
  // static const String baseUrl = 'http://localhost:5000/api';
  // static const String baseUrl = 'https://getinline-backend.onrender.com/api';
  static const String baseUrl = 'http://10.115.54.158:5000/api';
  // static const String baseUrl = 'http://10.115.54.158/api/health';
  // static const String baseUrl = 'https://your-backend-url.com/api';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyToken = '/auth/verify';
  static const String refreshToken = '/auth/refresh';
  

  // User Endpoints (userRoutes.js)
  static const String users = '/users';
  static const String getUserByUid = '/users/uid'; // Use as /users/uid/:uid
  static const String createUser = '/users/create';
  static const String updateProfile = '/users/profile';
  static const String updateFcmToken = '/users/fcm-token';
  static const String updateUserRole = '/users/role';
  static const String updateUserStatus = '/users/status';
  static String updateRoleByUid(String uid) => '/users/role/$uid';

  // Organization Endpoints (organizationRoutes.js)
  static const String searchOrganizations = '/organizations/search';
  static const String getOrgByQr = '/organizations/qr'; // Use as /organizations/qr/:qrId
  static const String createOrganization = '/organizations/create';
  static String getOrganizationById(String orgId) => '/organizations/$orgId';
  static String updateOrganization(String orgId) => '/organizations/$orgId';
  static String getOrganizationUsers(String orgId) => '/organizations/$orgId/users';
  static String removeUserFromOrg(String orgId, String userId) => '/organizations/$orgId/users/$userId';
  
  // Join Request Endpoints (joinRequestRoutes.js)
  static const String createJoinRequest = '/join-requests/create';
  static const String myJoinRequests = '/join-requests/my';
  static String orgJoinRequests(String orgId) => '/join-requests/organization/$orgId';
  static String acceptJoinRequest(String requestId) => '/join-requests/accept/$requestId';
  static String rejectJoinRequest(String requestId) => '/join-requests/reject/$requestId';
  
  // Professional Endpoints (professionalRoutes.js)
  static const String createProfessional = '/professionals/create';
  static String professionalsByOrg(String orgId) => '/professionals/organization/$orgId';
  static String getProfessionalByQr(String qrId) => '/professionals/qr/$qrId';
  static String getProfessionalById(String profId) => '/professionals/$profId';
  static String updateProfessional(String profId) => '/professionals/$profId';
  static String updateProfessionalStatus(String profId) => '/professionals/$profId/status';
  static String getProfessionalHistory(String profId) => '/professionals/$profId/history';
  
  // Leave Endpoints (leaveRoutes.js)
  static const String checkAvailability = '/leaves/check-availability';
  static String professionalLeaves(String profId) => '/leaves/professional/$profId';
  static const String createLeave = '/leaves/create';
  static String updateLeave(String leaveId) => '/leaves/$leaveId';
  static String deleteLeave(String leaveId) => '/leaves/$leaveId';
  
  // Appointment Endpoints (appointmentRoutes.js)
  static String getQueue(String profId) => '/appointments/queue/$profId';
  static String getProfessionalAppointments(String profId) => '/appointments/professional/$profId';
  static String cancelAppointment(String appId) => '/appointments/cancel/$appId';
  static const String checkAppointmentLimit = '/appointments/check-limit';
  static const String createAppointment = '/appointments/create';
  static const String myAppointments = '/appointments/my';
  static String organizationAppointments(String orgId) => '/appointments/organization/$orgId';
  static const String todayAppointments = '/appointments/today';
  static String updateAppointment(String appId) => '/appointments/$appId';
  
  // Transaction Endpoints (transactionRoutes.js)
  static const String createTransaction = '/transactions/create';
  static String appointmentTransactions(String appId) => '/transactions/appointment/$appId';
  static String organizationTransactions(String orgId) => '/transactions/organization/$orgId';
  
  // Notification Endpoints (notificationRoutes.js)
  static const String notifications = '/notifications';
  static const String markAllNotificationsRead = '/notifications/read-all';  
  static const String getUserNotifications = '/notifications/user';
  static String markNotificationRead(String notifyId) => '/notifications/$notifyId/read';
  static const String markAllRead = '/notifications/read-all';
  static String deleteNotification(String notifyId) => '/notifications/$notifyId';
  static const String deleteReadNotifications = '/notifications/delete-read';
  
  // Notify Endpoints (notifyRoutes.js)
  static const String notifies = '/notify'; 
  static const String createNotify = '/notify/create';
  static const String getUserNotifies = '/notify/user'; 
  static String deleteNotify(String notifyId) => '/notify/$notifyId';
  static const String getMyNotifies = '/notify/user';
  static const String checkNotifyExists = '/notify/check';  



  // Export Endpoints
  static const String exportAppointments = '/export/appointments';
  static const String exportExcel = '/export/excel';
  static const String exportPdf = '/export/pdf';
  static const String sendReceipt = '/export/receipt';
  static const String sendReceiptWhatsApp = '/export/receipt/whatsapp';
  static const String sendReceiptEmail = '/export/receipt/email';
  static const String sendReceiptSMS = '/export/receipt/sms';
}

// =============================================================================
// APP CONSTANTS
// =============================================================================

class AppConstants {
  // App Info
  static const String appName = 'GetInLine';
  static const String appVersion = '1.0.0';
  
  // Business Rules
  static const int maxAppointmentsPerDay = 3;
  static const int defaultMeetingTimeFrame = 15; // minutes
  static const int minMeetingTimeFrame = 15;
  static const int maxMeetingTimeFrame = 60;
  
  // Validation Limits
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int mobileLength = 10;
  static const int minAddressLength = 5;
  static const int maxAddressLength = 500;
  static const int minAge = 1;
  static const int maxAge = 150;
  static const int minDegreeLength = 2;
  static const int maxDegreeLength = 100;
  static const int minReasonLength = 5;
  static const int maxReasonLength = 500;
  static const int maxSlotsPerProfessional = 5;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  static const String serverDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  
  // Login Pages Name
  static const String organizationLoginPage = 'organizationLoginPage';
  static const String userLoginPage = 'userLoginPage';


  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleReceptionist = 'receptionist';
  static const String roleCustomer = 'customer';
  static const String roleProfessional = 'professional';
  
  static const List<String> organizationRoles = [
    roleAdmin,
    roleManager,
    roleReceptionist,
    roleProfessional,
  ];
  
  static const List<String> allRoles = [
    roleAdmin,
    roleManager,
    roleReceptionist,
    roleCustomer,
    roleProfessional,
  ];
  
  // Professional Status
  static const String statusIn = 'IN';
  static const String statusOut = 'OUT';
  
  static const List<String> professionalStatuses = [
    statusIn,
    statusOut,
  ];
  
  // Appointment Status
  static const String appointmentAccepted = 'Accepted';
  static const String appointmentPending = 'pending';
  static const String appointmentCancelled = 'cancelled';
  static const String appointmentInLine = 'InLine';
  
  static const List<String> appointmentStatuses = [
    appointmentAccepted,
    appointmentPending,
    appointmentInLine,
    appointmentCancelled,
  ];
  
  // Join Request Status
  static const String requestPending = 'pending';
  static const String requestAccepted = 'accepted';
  static const String requestRejected = 'rejected';
  
  static const List<String> requestStatuses = [
    requestPending,
    requestAccepted,
    requestRejected,
  ];
  
  // General Status
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusDeleted = 'deleted';
  
  // Payment Modes
  static const List<String> paymentModes = [
    'Cash',
    'PhonePe',
    'Google Pay',
    'Paytm',
    'Card',
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
    'UPI',
    'Other',
  ];
  
  // Days of Week
  static const List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  
  // Common Professions
  static const List<String> commonProfessions = [
    'Doctor',
    'Dentist',
    'Physician',
    'Surgeon',
    'Lawyer',
    'Advocate',
    'Engineer',
    'Consultant',
    'Therapist',
    'Psychologist',
    'Accountant',
    'Financial Advisor',
    'Architect',
    'Designer',
    'Other',
  ];
  
  // Time Slot Options (in minutes)
  static const List<int> timeSlotOptions = [15, 30, 45, 60];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

// =============================================================================
// VALIDATION MESSAGES
// =============================================================================

class ValidationMessages {
  // General
  static const String requiredField = 'This field is required';
  static const String invalidFormat = 'Invalid format';
  
  // Name
  static const String invalidName = 'Please enter a valid name (2-100 characters)';
  static const String nameRequired = 'Name is required';
  static const String nameTooShort = 'Name must be at least 2 characters';
  static const String nameTooLong = 'Name must not exceed 100 characters';
  
  // Mobile
  static const String invalidMobile = 'Please enter a valid 10-digit mobile number';
  static const String mobileRequired = 'Mobile number is required';
  static const String mobileLength = 'Mobile number must be exactly 10 digits';
  
  // Email
  static const String invalidEmail = 'Please enter a valid email address';
  static const String emailRequired = 'Email is required';
  
  // Address
  static const String invalidAddress = 'Please enter a valid address (5-500 characters)';
  static const String addressRequired = 'Address is required';
  static const String addressTooShort = 'Address must be at least 5 characters';
  static const String addressTooLong = 'Address must not exceed 500 characters';
  
  // Age
  static const String invalidAge = 'Please enter a valid age (1-150)';
  static const String ageRequired = 'Age is required';
  static const String ageTooLow = 'Age must be at least 1';
  static const String ageTooHigh = 'Age must not exceed 150';
  
  // Amount
  static const String invalidAmount = 'Please enter a valid amount';
  static const String amountRequired = 'Amount is required';
  static const String amountNegative = 'Amount must be positive';
  
  // Date & Time
  static const String invalidDate = 'Please select a valid date';
  static const String dateRequired = 'Date is required';
  static const String invalidTime = 'Please select a valid time';
  static const String timeRequired = 'Time is required';
  static const String endDateBeforeStart = 'End date must be after start date';
  static const String endTimeBeforeStart = 'End time must be after start time';
  static const String pastDate = 'Date cannot be in the past';
  static const String futureDate = 'Date cannot be in the future';
  
  // Selection
  static const String selectRole = 'Please select a role';
  static const String selectProfessional = 'Please select a professional';
  static const String selectOrganization = 'Please select an organization';
  static const String selectPaymentMode = 'Please select a payment mode';
  static const String selectStatus = 'Please select a status';
  static const String selectDate = 'Please select a date';
  static const String selectTime = 'Please select a time';
  
  // Business Rules
  static const String maxAppointmentsReached = 'You can only book 3 appointments per day';
  static const String professionalNotAvailable = 'Professional is not available';
  static const String professionalOnLeave = 'Professional is on leave for selected date';
  static const String slotOverlap = 'Time slots cannot overlap';
  static const String invalidTimeSlot = 'Invalid time slot';
  
  // Professional
  static const String degreeRequired = 'Degree is required';
  static const String professionRequired = 'Profession is required';
  static const String slotsRequired = 'At least one time slot is required';
  
  // Organization
  static const String organizationNameRequired = 'Organization name is required';
  static const String alreadyInOrganization = 'You are already in an organization';
  static const String notInOrganization = 'You are not part of any organization';
  
  // Authentication
  static const String loginFailed = 'Login failed. Please try again';
  static const String signupFailed = 'Signup failed. Please try again';
  static const String authenticationRequired = 'Please login to continue';
  
  // Network
  static const String networkError = 'Network error. Please check your connection';
  static const String serverError = 'Server error. Please try again later';
  static const String timeoutError = 'Request timeout. Please try again';
}

// =============================================================================
// STORAGE KEYS
// =============================================================================

class StorageKeys {
  static const String firstTimeUser = 'firstTimeUser';
  static const String loginPageName = 'loginPageName';
  static const String userId = 'userId';
  static const String userUid = 'userUid';
  static const String userToken = 'userToken';
  static const String fcmToken = 'fcmToken';
  static const String userRole = 'userRole';
  static const String organizationId = 'organizationId';
  static const String userName = 'userName';
  static const String userMobile = 'userMobile';
  static const String isLoggedIn = 'isLoggedIn';
  static const String rememberMe = 'rememberMe';
}

// =============================================================================
// ERROR MESSAGES
// =============================================================================

class ErrorMessages {
  static const String somethingWentWrong = 'Something went wrong. Please try again';
  static const String noInternetConnection = 'No internet connection';
  static const String dataNotFound = 'Data not found';
  static const String unableToLoadData = 'Unable to load data';
  static const String unableToSaveData = 'Unable to save data';
  static const String unableToDeleteData = 'Unable to delete data';
  static const String sessionExpired = 'Session expired. Please login again';
  static const String unauthorized = 'Unauthorized access';
  static const String forbidden = 'You do not have permission to perform this action';
}

// =============================================================================
// SUCCESS MESSAGES
// =============================================================================

class SuccessMessages {
  static const String loginSuccess = 'Login successful';
  static const String profileUpdated = 'Profile updated successfully';
  static const String organizationCreated = 'Organization created successfully';
  static const String requestSent = 'Request sent successfully';
  static const String appointmentCreated = 'Appointment created successfully';
  static const String appointmentUpdated = 'Appointment updated successfully';
  static const String appointmentCancelled = 'Appointment cancelled successfully';
  static const String paymentRecorded = 'Payment recorded successfully';
  static const String dataSaved = 'Data saved successfully';
  static const String dataDeleted = 'Data deleted successfully';
}
