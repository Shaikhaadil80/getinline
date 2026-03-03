// =============================================================================
// GETINLINE FLUTTER - providers/notification_provider.dart
// Notification State Management with Provider
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NotificationModel> _notifications = [];
  int _totalNotifications = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get totalNotifications => _totalNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.read).length;

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
  // GET USER NOTIFICATIONS
  // =============================================================================

  Future<void> getUserNotifications({
    bool unreadOnly = false,
    int limit = 50,
    int skip = 0,
    bool loadMore = false,
  }) async {
    if (!loadMore) _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        ApiConstants.getUserNotifications, // e.g., '/api/notifications/user'
        queryParams: {
          'unreadOnly': unreadOnly.toString(),
          'limit': limit.toString(),
          'skip': skip.toString(),
        },
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> notifData = response['notifications'] ?? [];
        final newNotifications = notifData.map((json) => NotificationModel.fromJson(json)).toList();

        if (loadMore) {
          _notifications.addAll(newNotifications);
        } else {
          _notifications = newNotifications;
        }

        if (response['pagination'] != null) {
          _totalNotifications = response['pagination']['total'] ?? 0;
        }
      } else {
        if (!loadMore) _notifications = [];
      }
    } catch (e) {
      print('❌ Get notifications error: $e');
      _setError('Failed to load notifications');
      if (!loadMore) _notifications = [];
    } finally {
      _setLoading(false);
    }
  }

  // =============================================================================
  // MARK AS READ
  // =============================================================================

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.notifications}/$notificationId/read', // e.g., '/api/notifications'
      );

      if (response != null && response['success'] == true) {
        // Update local state instantly
        final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].markAsRead();
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Mark as read error: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    _setLoading(true);
    try {
      final response = await _apiService.patch(
        ApiConstants.markAllNotificationsRead, // e.g., '/api/notifications/read-all'
      );

      if (response != null && response['success'] == true) {
        // Update local state instantly
        _notifications = _notifications.map((n) => n.markAsRead()).toList();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Mark all as read error: $e');
      _setError('Failed to mark all as read');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================================================================
  // DELETE NOTIFICATIONS
  // =============================================================================

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.notifications}/$notificationId', 
      );

      if (response != null && response['success'] == true) {
        // Remove from local list instantly
        _notifications.removeWhere((n) => n.notificationId == notificationId);
        _totalNotifications = (_totalNotifications > 0) ? _totalNotifications - 1 : 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Delete notification error: $e');
      return false;
    }
  }

  Future<bool> deleteReadNotifications() async {
    _setLoading(true);
    try {
      final response = await _apiService.delete(
        ApiConstants.deleteReadNotifications, // e.g., '/api/notifications/delete-read'
      );

      if (response != null && response['success'] == true) {
        // Remove from local list instantly
        final readCount = _notifications.where((n) => n.read).length;
        _notifications.removeWhere((n) => n.read);
        _totalNotifications = (_totalNotifications >= readCount) ? _totalNotifications - readCount : 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Delete read notifications error: $e');
      _setError('Failed to delete read notifications');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================================================================
  // CLEAR DATA
  // =============================================================================

  void clearNotificationData() {
    _notifications = [];
    _totalNotifications = 0;
    notifyListeners();
  }
}