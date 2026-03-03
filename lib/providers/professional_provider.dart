// =============================================================================
// GETINLINE FLUTTER - providers/professional_provider.dart
// Professional State Management with Provider
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/professional_model.dart';
import '../models/leave_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ProfessionalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProfessionalModel> _professionals = [];
  ProfessionalModel? _selectedProfessional;
  List<LeaveModel> _leaves = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProfessionalModel> get professionals => _professionals;
  ProfessionalModel? get selectedProfessional => _selectedProfessional;
  List<LeaveModel> get leaves => _leaves;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get available professionals (IN status and active)
  List<ProfessionalModel> get availableProfessionals =>
      _professionals.where((p) => p.isAvailable).toList();

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
  // CREATE/UPDATE PROFESSIONAL
  // =============================================================================

  Future<bool> createProfessional({
    required String name,
    required String profession,
    required String degree,
    required String mobile,
    required List<Map<String, String>> slots,
    required List<String> commonLeaves,
    required String organizationId,
    required bool isPaidAppointment,
    required double appointmentFees,
    required double minBookAppointmentFees,
    required int commonMeetingTimeFrame,
    required bool active,
    required String createdBy,
    String? remark,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('👨‍⚕️ Creating professional: $name');

      final response = await _apiService.post(
        ApiConstants.createProfessional,
        body: {
          'name': name,
          'profession': profession,
          'degree': degree,
          'mobile': mobile,
          'status': AppConstants.statusOut,
          'slots': slots,
          'commonLeaves': commonLeaves,
          'organizationId': organizationId,
          'isPaidAppointment': isPaidAppointment,
          'appointmentFees': appointmentFees,
          'minBookAppointmentFees': minBookAppointmentFees,
          'commonMeetingTimeFrame': commonMeetingTimeFrame,
          'active': active,
          'remark': remark,
          'createdBy': createdBy,
          'updatedBy': createdBy,
        },
      );

      if (response != null && response['professional'] != null) {
        final professional = ProfessionalModel.fromJson(response['professional']);
        _professionals.add(professional);
        
        print('✅ Professional created');
        _setLoading(false);
        return true;
      }

      throw Exception('Failed to create professional');
    } catch (e) {
      print('❌ Create professional error: $e');
      _setError('Failed to create professional: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfessional({
    required String professionalId,
    required String name,
    required String profession,
    required String degree,
    required String mobile,
    required List<Map<String, String>> slots,
    required List<String> commonLeaves,
    required bool isPaidAppointment,
    required double appointmentFees,
    required double minBookAppointmentFees,
    required int commonMeetingTimeFrame,
    required bool active,
    required String updatedBy,
    String? remark,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('👨‍⚕️ Updating professional: $professionalId');

      final response = await _apiService.put(
        '${ApiConstants.updateProfessional}/$professionalId',
        body: {
          'name': name,
          'profession': profession,
          'degree': degree,
          'mobile': mobile,
          'slots': slots,
          'commonLeaves': commonLeaves,
          'isPaidAppointment': isPaidAppointment,
          'appointmentFees': appointmentFees,
          'minBookAppointmentFees': minBookAppointmentFees,
          'commonMeetingTimeFrame': commonMeetingTimeFrame,
          'active': active,
          'remark': remark,
          'updatedBy': updatedBy,
        },
      );

      if (response != null && response['professional'] != null) {
        final updated = ProfessionalModel.fromJson(response['professional']);
        final index = _professionals.indexWhere((p) => p.professionalId == professionalId);
        if (index != -1) {
          _professionals[index] = updated;
        }
        
        print('✅ Professional updated');
        _setLoading(false);
        return true;
      }

      throw Exception('Failed to update professional');
    } catch (e) {
      print('❌ Update professional error: $e');
      _setError('Failed to update professional: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================================================================
  // GET PROFESSIONALS
  // =============================================================================

  Future<void> getProfessionalsByOrganization(String organizationId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get(
        '${ApiConstants.professionalsByOrg}/$organizationId',
      );

      if (response != null && response['professionals'] != null) {
        _professionals = (response['professionals'] as List)
            .map((json) => ProfessionalModel.fromJson(json))
            .toList();
      } else {
        _professionals = [];
      }

      _setLoading(false);
    } catch (e) {
      print('❌ Get professionals error: $e');
      _setError('Failed to load professionals: $e');
      _professionals = [];
      _setLoading(false);
    }
  }

  Future<ProfessionalModel?> getProfessionalById(String professionalId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.getProfessionalById}/$professionalId',
      );

      if (response != null && response['professional'] != null) {
        _selectedProfessional = ProfessionalModel.fromJson(response['professional']);
        notifyListeners();
        return _selectedProfessional;
      }
      return null;
    } catch (e) {
      print('❌ Get professional error: $e');
      return null;
    }
  }

  Future<ProfessionalModel?> getProfessionalByQr(String qrId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.getProfessionalByQr}/$qrId',
      );

      if (response != null && response['professional'] != null) {
        return ProfessionalModel.fromJson(response['professional']);
      }
      return null;
    } catch (e) {
      print('❌ Get professional by QR error: $e');
      return null;
    }
  }

  // =============================================================================
  // UPDATE STATUS (IN/OUT)
  // =============================================================================

  Future<bool> updateProfessionalStatus({
    required String professionalId,
    required String status,
    String? note,
  }) async {
    try {
      print('🔄 Updating professional status: $status');

      final response = await _apiService.patch(
        '${ApiConstants.updateProfessionalStatus(professionalId)}',
        body: {
          'status': status,
          'inOutNote': note,
        },
      );

      if (response != null && response['professional'] != null) {
        final updated = ProfessionalModel.fromJson(response['professional']);
        final index = _professionals.indexWhere((p) => p.professionalId == professionalId);
        if (index != -1) {
          _professionals[index] = updated;
          notifyListeners();
        }
        
        print('✅ Status updated to: $status');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Update status error: $e');
      return false;
    }
  }

  // =============================================================================
  // LEAVES MANAGEMENT
  // =============================================================================

  Future<void> getProfessionalLeaves(String professionalId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.professionalLeaves}/$professionalId',
      );

      if (response != null && response['leaves'] != null) {
        _leaves = (response['leaves'] as List)
            .map((json) => LeaveModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Get leaves error: $e');
    }
  }

  Future<bool> createLeave({
    required String professionalId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('📅 Creating leave...');

      final response = await _apiService.post(
        ApiConstants.createLeave,
        body: {
          'professionalId': professionalId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'reason': reason,
        },
      );

      if (response != null && response['leave'] != null) {
        final leave = LeaveModel.fromJson(response['leave']);
        _leaves.add(leave);
        
        print('✅ Leave created');
        _setLoading(false);
        return true;
      }

      throw Exception('Failed to create leave');
    } catch (e) {
      print('❌ Create leave error: $e');
      _setError('Failed to create leave: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteLeave(String leaveId) async {
    try {
      await _apiService.delete('${ApiConstants.deleteLeave}/$leaveId');
      _leaves.removeWhere((l) => l.leaveId == leaveId);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Delete leave error: $e');
      return false;
    }
  }

  // Check if professional is on leave for a specific date
  Future<bool> checkLeaveAvailability({
    required String professionalId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.checkAvailability,
        body: {
          'professionalId': professionalId,
          'date': date.toIso8601String(),
        },
      );

      if (response != null) {
        return response['isAvailable'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Check leave availability error: $e');
      return false;
    }
  }
// =============================================================================
// MISSING: UPDATE LEAVE (leaveRoutes.js)
// =============================================================================
Future<bool> updateLeave({
  required String leaveId,
  required DateTime startDate,
  required DateTime endDate,
  required String reason,
}) async {
  try {
    final response = await _apiService.patch(
      ApiConstants.updateLeave(leaveId),
      body: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'reason': reason,
      },
    );
    if (response != null && response['leave'] != null) {
      // Refresh list or update locally
      final updated = LeaveModel.fromJson(response['leave']);
      final index = _leaves.indexWhere((l) => l.leaveId == leaveId);
      if (index != -1) {
        _leaves[index] = updated;
        notifyListeners();
      }
      return true;
    }
    return false;
  } catch (e) {
    print('❌ Update leave error: $e');
    return false;
  }
}

// =============================================================================
// MISSING: GET PROFESSIONAL STATUS HISTORY (professionalRoutes.js)
// =============================================================================
Future<List<dynamic>> getProfessionalHistory(String professionalId) async {
  try {
    final response = await _apiService.get(
      ApiConstants.getProfessionalHistory(professionalId)
    );
    return response?['history'] ?? [];
  } catch (e) {
    print('❌ Get professional history error: $e');
    return [];
  }
}
  // =============================================================================
  // CLEAR DATA
  // =============================================================================

  void clearProfessionalData() {
    _professionals = [];
    _selectedProfessional = null;
    _leaves = [];
    notifyListeners();
  }
}
