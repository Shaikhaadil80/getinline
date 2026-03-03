// =============================================================================
// GETINLINE FLUTTER - providers/notify_provider.dart
// Notify State Management for Professional Alerts
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:getinline/services/notification_service.dart';
import '../models/notify_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class NotifyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NotifyModel> _notifies = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NotifyModel> get notifies => _notifies;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
  // GET SUBSCRIPTIONS
  // =============================================================================

  Future<void> getUserNotifies() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        ApiConstants.getUserNotifies, // e.g., '/api/notify/user'
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> notifyData = response['notifies'] ?? [];
        _notifies = notifyData.map((json) => NotifyModel.fromJson(json)).toList();
      } else {
        _notifies = [];
      }
    } catch (e) {
      print('❌ Get user notifies error: $e');
      _setError('Failed to load subscriptions');
      _notifies = [];
    } finally {
      _setLoading(false);
    }
  }

  // =============================================================================
  // CREATE & DELETE SUBSCRIPTIONS
  // =============================================================================

  Future<bool> createNotify({
    required String professionalId,
    required String organizationId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(
        ApiConstants.createNotify, // e.g., '/api/notify/create'
        body: {
          'professionalId': professionalId,
          'organizationId': organizationId,
        },
      );

      if (response != null && response['success'] == true && response['notify'] != null) {
        final newNotify = NotifyModel.fromJson(response['notify']);
        // Add to local state instantly
        _notifies.insert(0, newNotify);

        // =====================================================================
        // NEW: Subscribe to Firebase Topic
        // The backend uses topic format: `prof_${professionalId}`
        // =====================================================================
        await NotificationService().subscribeToTopic('prof_$professionalId');

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Create notify error: $e');
      _setError('Failed to subscribe: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteNotify(String notifyId,  {String? professionalId}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.delete(
        '${ApiConstants.notifies}/$notifyId', // e.g., '/api/notify'
      );

      if (response != null && response['success'] == true) {
        // =====================================================================
        // NEW: Unsubscribe from Firebase Topic
        // =====================================================================
        // If we know the professionalId, unsubscribe. 
        // We find it from the local list before removing it.
        final notifyToRemove = _notifies.firstWhere(
          (n) => n.notifyId == notifyId, 
          orElse: () => NotifyModel(
            notifyId: '', userId: '', professionalId: professionalId ?? '', organizationId: '', createdAt: DateTime.now()
          )
        );
        
        if (notifyToRemove.professionalId.isNotEmpty) {
          await NotificationService().unsubscribeFromTopic('prof_${notifyToRemove.professionalId}');
        }
        // Remove from local list instantly
        _notifies.removeWhere((n) => n.notifyId == notifyId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Delete notify error: $e');
      _setError('Failed to unsubscribe');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================================================================
  // CHECK SUBSCRIPTION
  // =============================================================================

  Future<bool> checkNotifyExists(String professionalId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.checkNotifyExists, // e.g., '/api/notify/check'
        queryParams: {'professionalId': professionalId},
      );

      if (response != null && response['success'] == true) {
        return response['subscribed'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Check notify exists error: $e');
      return false;
    }
  }

  // =============================================================================
  // CLEAR DATA
  // =============================================================================

  void clearNotifyData() {
    _notifies = [];
    notifyListeners();
  }
}