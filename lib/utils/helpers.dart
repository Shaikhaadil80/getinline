// =============================================================================
// GETINLINE FLUTTER - utils/helpers.dart
// Validation, Formatting, and UI Helper Functions
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

// =============================================================================
// VALIDATORS
// =============================================================================

class Validators {
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.nameRequired;
    }
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minNameLength) {
      return ValidationMessages.nameTooShort;
    }
    if (trimmed.length > AppConstants.maxNameLength) {
      return ValidationMessages.nameTooLong;
    }
    // Check for valid characters (letters, spaces, and common punctuation)
    final nameRegex = RegExp(r"^[a-zA-Z\s\.\-']+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return ValidationMessages.invalidName;
    }
    return null;
  }

  // Mobile validation
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.mobileRequired;
    }
    // Remove all non-digit characters
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.length != AppConstants.mobileLength) {
      return ValidationMessages.mobileLength;
    }
    // Check if starts with valid digit (6-9 for Indian numbers)
    if (!RegExp(r'^[6-9]').hasMatch(cleanValue)) {
      return ValidationMessages.invalidMobile;
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.emailRequired;
    }
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return ValidationMessages.invalidEmail;
    }
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.addressRequired;
    }
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minAddressLength) {
      return ValidationMessages.addressTooShort;
    }
    if (trimmed.length > AppConstants.maxAddressLength) {
      return ValidationMessages.addressTooLong;
    }
    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.ageRequired;
    }
    final age = int.tryParse(value.trim());
    if (age == null) {
      return ValidationMessages.invalidAge;
    }
    if (age < AppConstants.minAge) {
      return ValidationMessages.ageTooLow;
    }
    if (age > AppConstants.maxAge) {
      return ValidationMessages.ageTooHigh;
    }
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value, {bool allowZero = false}) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.amountRequired;
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return ValidationMessages.invalidAmount;
    }
    if (!allowZero && amount <= 0) {
      return ValidationMessages.amountNegative;
    }
    if (allowZero && amount < 0) {
      return ValidationMessages.amountNegative;
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName is required' 
          : ValidationMessages.requiredField;
    }
    return null;
  }

  // Dropdown validation
  static String? validateDropdown(dynamic value, {String? fieldName}) {
    if (value == null) {
      return fieldName != null 
          ? 'Please select $fieldName' 
          : ValidationMessages.requiredField;
    }
    return null;
  }

  // Degree validation
  static String? validateDegree(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.degreeRequired;
    }
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minDegreeLength) {
      return 'Degree must be at least ${AppConstants.minDegreeLength} characters';
    }
    if (trimmed.length > AppConstants.maxDegreeLength) {
      return 'Degree must not exceed ${AppConstants.maxDegreeLength} characters';
    }
    return null;
  }

  // Reason/Remark validation (optional but with limits)
  static String? validateReason(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Reason is required' : null;
    }
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minReasonLength) {
      return 'Reason must be at least ${AppConstants.minReasonLength} characters';
    }
    if (trimmed.length > AppConstants.maxReasonLength) {
      return 'Reason must not exceed ${AppConstants.maxReasonLength} characters';
    }
    return null;
  }

  // Password validation (if needed)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // URL validation (if needed)
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }
    return null;
  }
}

// =============================================================================
// DATE TIME HELPER
// =============================================================================

class DateTimeHelper {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  // Format time
  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat(AppConstants.timeFormat).format(dateTime);
  }

  // Format DateTime
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  // Format time from DateTime
  static String formatTimeFromDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.timeFormat).format(dateTime);
  }

  // Parse date string
  static DateTime? parseDate(String dateStr) {
    try {
      return DateFormat(AppConstants.dateFormat).parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Parse time string
  static TimeOfDay? parseTime(String timeStr) {
    try {
      final dateTime = DateFormat(AppConstants.timeFormat).parse(timeStr);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      return null;
    }
  }

  // Parse DateTime from server format
  static DateTime? parseServerDateTime(String dateTimeStr) {
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  // Format DateTime for server
  static String formatForServer(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  // Check if date is in future
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  // Check if date is in past
  static bool isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  // Get day name
  static String getDayName(DateTime date) {
    return AppConstants.daysOfWeek[date.weekday % 7];
  }

  // Check if dates are same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Add minutes to time string
  static String addMinutesToTime(String timeStr, int minutes) {
    try {
      final time = DateFormat(AppConstants.timeFormat).parse(timeStr);
      final newTime = time.add(Duration(minutes: minutes));
      return DateFormat(AppConstants.timeFormat).format(newTime);
    } catch (e) {
      return timeStr;
    }
  }

  // Calculate time difference in minutes
  static int getTimeDifferenceInMinutes(String startTime, String endTime) {
    try {
      final start = DateFormat(AppConstants.timeFormat).parse(startTime);
      final end = DateFormat(AppConstants.timeFormat).parse(endTime);
      return end.difference(start).inMinutes;
    } catch (e) {
      return 0;
    }
  }

  // Get relative date string (Today, Tomorrow, etc.)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      final difference = date.difference(DateTime.now()).inDays;
      if (difference > 0 && difference < 7) {
        return getDayName(date);
      }
      return formatDate(date);
    }
  }

  // Get time ago string
  static String getTimeAgoString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

// =============================================================================
// UI HELPER
// =============================================================================

class UIHelper {
  // Show snackbar
  static void showSnackBar(
    BuildContext context, 
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous 
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show error dialog
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error, color: AppColors.error),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show success dialog
  static void showSuccessDialog(
    BuildContext context, 
    String message, {
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onClose != null) onClose();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show info dialog
  static void showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: AppColors.info),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show bottom sheet
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }
}

// =============================================================================
// STRING HELPER
// =============================================================================

class StringHelper {
  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalize each word
  static String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Format mobile number
  static String formatMobileNumber(String mobile) {
    final clean = mobile.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.length == 10) {
      return '${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return mobile;
  }

  // Format currency
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Truncate text
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get initials
  static String getInitials(String name, {int maxInitials = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.take(maxInitials).map((word) => word[0].toUpperCase()).join();
    return initials;
  }

  // Remove extra spaces
  static String removeExtraSpaces(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Check if string is numeric
  static bool isNumeric(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }

  // Clean mobile number (remove all non-digits)
  static String cleanMobileNumber(String mobile) {
    return mobile.replaceAll(RegExp(r'[^\d]'), '');
  }
}

// =============================================================================
// COLOR HELPER
// =============================================================================

class ColorHelper {
  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in':
        return AppColors.inStatus;
      case 'out':
        return AppColors.outStatus;
      case 'accepted':
        return AppColors.acceptedStatus;
      case 'pending':
        return AppColors.pendingStatus;
      case 'cancelled':
        return AppColors.cancelledStatus;
      case 'inline':
        return AppColors.inLineStatus;
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  // Get role color
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'manager':
        return AppColors.warning;
      case 'receptionist':
        return AppColors.info;
      case 'professional':
        return AppColors.success;
      case 'customer':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}
