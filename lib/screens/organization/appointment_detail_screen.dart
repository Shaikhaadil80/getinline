// =============================================================================
// GETINLINE FLUTTER - screens/customer/appointment_detail_screen.dart
// Appointment Detail with Queue Tracking and Real-Time Updates
// =============================================================================

import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  AppointmentModel? _appointment;
  int? _queuePosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadAppointmentDetails();
    });
  }

  Future<void> _loadAppointmentDetails() async {
    setState(() => _isLoading = true);

    try {
      // Mock loading - In real app, fetch from provider
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock appointment data
      _appointment = AppointmentModel(
        appointmentId: widget.appointmentId,
        name: 'John Doe',
        age: 30,
        mobileNo: '9876543210',
        address: '123 Main Street, City',
        organizationId: 'org123',
        professionalId: 'prof123',
        appointmentDate: DateTime.now(),
        appointmentExpectedTime: '10:30 AM',
        status: AppConstants.appointmentInLine,
        registeredByOrganization: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user123',
        updatedBy: 'user123',
      );
      
      _queuePosition = 3; // Mock queue position
    } catch (e) {
      print('❌ Error loading appointment: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        actions: [
          if (_appointment?.canBeCancelled == true)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _handleCancelAppointment,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _appointment == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      const Text('Appointment not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppointmentDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        _buildStatusCard(),
                        const SizedBox(height: 16),

                        // Queue Position (if in line)
                        if (_appointment!.isInLine && _queuePosition != null)
                          _buildQueueCard(),
                        const SizedBox(height: 16),

                        // Patient Information
                        _buildSectionCard(
                          'Patient Information',
                          Icons.person,
                          [
                            _buildInfoRow('Name', _appointment!.name),
                            _buildInfoRow('Age', '${_appointment!.age} years'),
                            _buildInfoRow('Mobile', StringHelper.formatMobileNumber(_appointment!.mobileNo)),
                            _buildInfoRow('Address', _appointment!.address),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Appointment Information
                        _buildSectionCard(
                          'Appointment Details',
                          Icons.event,
                          [
                            _buildInfoRow('Date', DateTimeHelper.formatDate(_appointment!.appointmentDate)),
                            _buildInfoRow('Expected Time', _appointment!.appointmentExpectedTime),
                            _buildInfoRow('Status', _appointment!.status),
                            _buildInfoRow(
                              'Booked',
                              _appointment!.registeredByOrganization ? 'By Organization' : 'By You',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Instructions
                        _buildInstructionsCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    final color = ColorHelper.getStatusColor(_appointment!.status);
    final isInLine = _appointment!.isInLine;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            isInLine ? Icons.schedule : _appointment!.isAccepted ? Icons.check_circle : Icons.pending,
            size: 64,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            _appointment!.status.toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_queuePosition',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Queue Position',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _queuePosition == 1
                      ? 'Your turn next!'
                      : '$_queuePosition ${_queuePosition! > 2 ? 'people' : 'person'} ahead',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      color: AppColors.info.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.info),
                SizedBox(width: 12),
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('Arrive 10 minutes before your expected time'),
            _buildInstructionItem('Keep your mobile phone charged for notifications'),
            _buildInstructionItem('Bring any relevant documents or prescriptions'),
            _buildInstructionItem('Pull down to refresh for updated queue position'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage() {
    switch (_appointment!.status.toLowerCase()) {
      case 'accepted':
        return 'Your appointment has been confirmed';
      case 'pending':
        return 'Waiting for confirmation';
      case 'inline':
        return 'You are in the queue';
      case 'cancelled':
        return 'This appointment was cancelled';
      default:
        return '';
    }
  }

  Future<void> _handleCancelAppointment() async {
    final confirm = await UIHelper.showConfirmationDialog(
      context,
      title: 'Cancel Appointment',
      message: 'Are you sure you want to cancel this appointment?',
      confirmText: 'Cancel Appointment',
      isDangerous: true,
    );

    if (!confirm) return;

    UIHelper.showLoadingDialog(context, message: 'Cancelling...');

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);
      
      UIHelper.showSnackBar(context, 'Appointment cancelled');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        UIHelper.hideLoadingDialog(context);
        UIHelper.showSnackBar(context, 'Failed to cancel', isError: true);
      }
    }
  }
}
