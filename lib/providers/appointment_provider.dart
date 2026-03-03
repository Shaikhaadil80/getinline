// =============================================================================
// GETINLINE FLUTTER - providers/appointment_provider.dart
// Appointment State Management with Provider
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _myAppointments = [];
  List<AppointmentModel> _queueAppointments = [];
  List<TransactionModel> _transactions = [];
  AppointmentModel? _selectedAppointment;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get myAppointments => _myAppointments;
  List<AppointmentModel> get queueAppointments => _queueAppointments;
  List<TransactionModel> get transactions => _transactions;
  AppointmentModel? get selectedAppointment => _selectedAppointment;
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
  // CREATE/UPDATE APPOINTMENT
  // =============================================================================

  Future<bool> createAppointment({
    required String name,
    required int age,
    required String mobileNo,
    required String address,
    required String organizationId,
    required String professionalId,
    required DateTime appointmentDate,
    required String createdBy,
    bool registeredByOrganization = true,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('📅 Creating appointment for: $name');

      // Check appointment limit for customer
      if (!registeredByOrganization) {
        final canBook = await checkAppointmentLimit(createdBy, appointmentDate);
        if (!canBook) {
          throw Exception(ValidationMessages.maxAppointmentsReached);
        }
      }

      final response = await _apiService.post(
        ApiConstants.createAppointment,
        body: {
          'name': name,
          'age': age,
          'mobileNo': mobileNo,
          'address': address,
          'organizationId': organizationId,
          'professionalId': professionalId,
          'appointmentDate': appointmentDate.toIso8601String(),
          'registeredByOrganization': registeredByOrganization,
          'status': AppConstants.appointmentAccepted,
          'createdBy': createdBy,
          'updatedBy': createdBy,
        },
      );

      if (response != null && response['appointment'] != null) {
        final appointment = AppointmentModel.fromJson(response['appointment']);
        _appointments.add(appointment);
        
        print('✅ Appointment created');
        _setLoading(false);
        return true;
      }

      throw Exception('Failed to create appointment');
    } catch (e) {
      print('❌ Create appointment error: $e');
      _setError('Failed to create appointment: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateAppointment({
    required String appointmentId,
    required String name,
    required int age,
    required String mobileNo,
    required String address,
    required DateTime appointmentDate,
    required String updatedBy,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('📅 Updating appointment: $appointmentId');

      final response = await _apiService.put(
        '${ApiConstants.updateAppointment}/$appointmentId',
        body: {
          'name': name,
          'age': age,
          'mobileNo': mobileNo,
          'address': address,
          'appointmentDate': appointmentDate.toIso8601String(),
          'updatedBy': updatedBy,
        },
      );

      if (response != null && response['appointment'] != null) {
        final updated = AppointmentModel.fromJson(response['appointment']);
        final index = _appointments.indexWhere((a) => a.appointmentId == appointmentId);
        if (index != -1) {
          _appointments[index] = updated;
        }
        
        print('✅ Appointment updated');
        _setLoading(false);
        return true;
      }

      throw Exception('Failed to update appointment');
    } catch (e) {
      print('❌ Update appointment error: $e');
      _setError('Failed to update appointment: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================================
  // GET APPOINTMENTS
  // =============================================================================

  Future<void> getMyAppointments(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get('${ApiConstants.myAppointments}');
      // final response = await _apiService.get('${ApiConstants.myAppointments}/$userId');

      if (response != null && response['appointments'] != null) {
        _myAppointments = (response['appointments'] as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        _myAppointments = [];
      }

      _setLoading(false);
    } catch (e) {
      print('❌ Get my appointments error: $e');
      _setError('Failed to load appointments: $e');
      _myAppointments = [];
      _setLoading(false);
    }
  }

  Future<void> getOrganizationAppointments(String organizationId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        '${ApiConstants.organizationAppointments}/$organizationId',
      );

      if (response != null && response['appointments'] != null) {
        _appointments = (response['appointments'] as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        _appointments = [];
      }

      _setLoading(false);
    } catch (e) {
      print('❌ Get organization appointments error: $e');
      _setError('Failed to load appointments: $e');
      _appointments = [];
      _setLoading(false);
    }
  }

  Future<void> getProfessionalAppointments(String professionalId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        '${ApiConstants.getProfessionalAppointments(professionalId)}',
      );

      if (response != null && response['appointments'] != null) {
        _appointments = (response['appointments'] as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        _appointments = [];
      }

      _setLoading(false);
    } catch (e) {
      print('❌ Get professional appointments error: $e');
      _setError('Failed to load appointments: $e');
      _appointments = [];
      _setLoading(false);
    }
  }

  Future<void> getAppointmentQueue({
    required String professionalId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.getQueue(professionalId)}',
        queryParams: {
          'date': DateTimeHelper.formatDate(date),
        },
      );

      if (response != null && response['queue'] != null) {
        _queueAppointments = (response['queue'] as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Get appointment queue error: $e');
    }
  }

  // =============================================================================
  // CANCEL APPOINTMENT
  // =============================================================================

  Future<bool> cancelAppointment(String appointmentId, String cancelledBy) async {
    _setLoading(true);
    _setError(null);

    try {
      print('❌ Cancelling appointment: $appointmentId');

      await _apiService.post(
        '${ApiConstants.cancelAppointment}/$appointmentId',
        body: {'cancelledBy': cancelledBy},
      );

      // Update local lists
      _appointments.removeWhere((a) => a.appointmentId == appointmentId);
      _myAppointments.removeWhere((a) => a.appointmentId == appointmentId);
      
      print('✅ Appointment cancelled');
      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ Cancel appointment error: $e');
      _setError('Failed to cancel appointment: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================================
  // CHECK APPOINTMENT LIMIT
  // =============================================================================

  Future<bool> checkAppointmentLimit(String userId, DateTime date) async {
    try {
      final response = await _apiService.post(
        ApiConstants.checkAppointmentLimit,
        body: {
          'userId': userId,
          'date': date.toIso8601String(),
        },
      );

      if (response != null) {
        return response['canBook'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Check appointment limit error: $e');
      return false;
    }
  }

  // =============================================================================
  // TRANSACTIONS
  // =============================================================================

  Future<void> getAppointmentTransactions(String appointmentId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.appointmentTransactions}/$appointmentId',
      );

      if (response != null && response['transactions'] != null) {
        _transactions = (response['transactions'] as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Get transactions error: $e');
    }
  }

  Future<bool> createTransaction({
    required String appointmentId,
    required double amountPaid,
    required String paymentMode,
    required DateTime paymentDate,
    required String createdBy,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createTransaction,
        body: {
          'appointmentId': appointmentId,
          'amountPaid': amountPaid,
          'paymentMode': paymentMode,
          'paymentDate': paymentDate.toIso8601String(),
          'remarks': remarks,
          'createdBy': createdBy,
        },
      );

      if (response != null && response['transaction'] != null) {
        final transaction = TransactionModel.fromJson(response['transaction']);
        _transactions.add(transaction);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Create transaction error: $e');
      return false;
    }
  }

// =============================================================================
// MISSING: GET TODAY'S APPOINTMENTS (appointmentRoutes.js)
// =============================================================================
Future<void> getTodayAppointments() async {
  _setLoading(true);
  try {
    final response = await _apiService.get(ApiConstants.todayAppointments);
    if (response != null && response['appointments'] != null) {
      _appointments = (response['appointments'] as List)
          .map((json) => AppointmentModel.fromJson(json)).toList();
      notifyListeners();
    }
  } catch (e) {
    print('❌ Get today appointments error: $e');
  } finally {
    _setLoading(false);
  }
}

// =============================================================================
// MISSING: GET ORGANIZATION TRANSACTIONS (transactionRoutes.js)
// =============================================================================
Future<void> getOrganizationTransactions(String organizationId) async {
  try {
    final response = await _apiService.get(
      ApiConstants.organizationTransactions(organizationId),
    );
    if (response != null && response['transactions'] != null) {
      _transactions = (response['transactions'] as List)
          .map((json) => TransactionModel.fromJson(json)).toList();
      notifyListeners();
    }
  } catch (e) {
    print('❌ Get organization transactions error: $e');
  }
}
  // =============================================================================
  // CLEAR DATA
  // =============================================================================

  void clearAppointmentData() {
    _appointments = [];
    _myAppointments = [];
    _queueAppointments = [];
    _transactions = [];
    _selectedAppointment = null;
    notifyListeners();
  }
}
