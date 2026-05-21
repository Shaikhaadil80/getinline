import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../providers/appointment_provider.dart';
import '../../../models/appointment_model.dart';
import '../../../models/professional_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/loading_widget.dart';

class ManageQueueScreen extends StatefulWidget {
  final ProfessionalModel professional;
  final DateTime selectedDate;

  const ManageQueueScreen({
    super.key,
    required this.professional,
    required this.selectedDate,
  });

  @override
  State<ManageQueueScreen> createState() => _ManageQueueScreenState();
}

class _ManageQueueScreenState extends State<ManageQueueScreen> {
  Timer? _pollingTimer;
  AppointmentModel? _currentAppointment;
  bool _isLoading = true;
  
  int _totalServed = 0;
  int _totalCancelled = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
    // Start polling to mimic real-time listener updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData(isSilent: true));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool isSilent = false}) async {
    if (!mounted) return;
    if (!isSilent) setState(() => _isLoading = true);

    final provider = context.read<AppointmentProvider>();

    try {
      await provider.getAppointmentQueue(
        professionalId: widget.professional.professionalId,
        date: widget.selectedDate,
      );

      if (provider.queueAppointments.isNotEmpty && _currentAppointment == null) {
        _currentAppointment = provider.queueAppointments.first;
      }

      await provider.getProfessionalAppointments(widget.professional.professionalId);
      _calculateStatistics(provider.appointments);
    } catch (e) {
      if (!isSilent && mounted) {
        UIHelper.showSnackBar(context, 'Failed to load data.', isError: true);
      }
    } finally {
      if (mounted && !isSilent) setState(() => _isLoading = false);
    }
  }

  void _calculateStatistics(List<AppointmentModel> allAppointments) {
    if (!mounted) return;
    
    final todayAppointments = allAppointments.where((app) {
      return app.appointmentDate.year == widget.selectedDate.year &&
             app.appointmentDate.month == widget.selectedDate.month &&
             app.appointmentDate.day == widget.selectedDate.day;
    }).toList();

    setState(() {
      _totalServed = todayAppointments.where((a) => a.status == 'completed').length;
      _totalCancelled = todayAppointments.where((a) => a.status == 'cancelled').length;
    });
  }

  Future<void> _callNextPatient(List<AppointmentModel> queueList) async {
    if (queueList.isEmpty) return;
    final nextAppointment = queueList.first;
    final provider = context.read<AppointmentProvider>();

    try {
      await provider.updateAppointmentStatus(
        appointmentId: nextAppointment.appointmentId,
        status: 'inLine',
        updatedBy: 'Staff', // Or user ID
      );

      setState(() => _currentAppointment = nextAppointment);
      if (mounted) UIHelper.showSnackBar(context, 'Called: ${nextAppointment.name}');
      _fetchData(isSilent: true); 
    } catch (e) {
      if (mounted) UIHelper.showSnackBar(context, 'Failed to call patient', isError: true);
    }
  }

  Future<void> _completeAppointment(AppointmentModel appointment) async {
    final confirmed = await UIHelper.showConfirmationDialog(
      context,
      title: 'Complete Appointment',
      message: 'Mark this appointment as completed?',
      confirmText: 'Complete',
    );
    if (!confirmed) return;

    final provider = context.read<AppointmentProvider>();

    try {
      await provider.updateAppointmentStatus(
        appointmentId: appointment.appointmentId,
        status: 'completed',
        updatedBy: 'Staff',
      );

      setState(() {
        if (_currentAppointment?.appointmentId == appointment.appointmentId) {
          _currentAppointment = null;
        }
      });

      if (mounted) UIHelper.showSnackBar(context, 'Appointment completed');
      _fetchData(isSilent: true);
    } catch (e) {
      if (mounted) UIHelper.showSnackBar(context, 'Failed to complete appointment', isError: true);
    }
  }

  Future<void> _skipAppointment(AppointmentModel appointment) async {
    final confirmed = await UIHelper.showConfirmationDialog(
      context,
      title: 'Skip Appointment',
      message: 'Move this appointment to the end of the queue?',
      confirmText: 'Skip',
    );
    if (!confirmed) return;

    final provider = context.read<AppointmentProvider>();

    try {
      await provider.skipAppointment(appointmentId: appointment.appointmentId, updatedBy: 'Staff');
      if (mounted) UIHelper.showSnackBar(context, 'Moved to end of queue');
      _fetchData(isSilent: true);
    } catch (e) {
      if (mounted) UIHelper.showSnackBar(context, 'Failed to skip appointment', isError: true);
    }
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    final confirmed = await UIHelper.showConfirmationDialog(
      context,
      title: 'Cancel Appointment',
      message: 'Are you sure you want to cancel this appointment?',
      confirmText: 'Cancel Appointment',
      isDangerous: true,
    );
    if (!confirmed) return;

    final provider = context.read<AppointmentProvider>();

    try {
      await provider.cancelAppointment(appointment.appointmentId, 'Staff/Admin');

      setState(() {
        if (_currentAppointment?.appointmentId == appointment.appointmentId) {
          _currentAppointment = null;
        }
      });

      if (mounted) UIHelper.showSnackBar(context, 'Appointment cancelled');
      _fetchData(isSilent: true);
    } catch (e) {
      if (mounted) UIHelper.showSnackBar(context, 'Failed to cancel appointment', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Queue'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchData(),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading queue data...')
          : Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                final queueList = provider.queueAppointments;
                return RefreshIndicator(
                  onRefresh: () async => await _fetchData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 16),
                      _buildStatisticsGrid(queueList.length),
                      const SizedBox(height: 24),
                      if (_currentAppointment != null) ...[
                        _buildCurrentPatientCard(),
                        const SizedBox(height: 24),
                      ],
                      _buildQueueSection(queueList),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: !_isLoading && context.watch<AppointmentProvider>().queueAppointments.isNotEmpty && _currentAppointment == null
          ? FloatingActionButton.extended(
              onPressed: () => _callNextPatient(context.read<AppointmentProvider>().queueAppointments),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.phone_forwarded, color: Colors.white),
              label: const Text('Call Next', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildHeaderCard() {
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
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  radius: 24,
                  child: Icon(Icons.medical_services, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.professional.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.professional.profession,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  DateTimeHelper.formatDate(widget.selectedDate),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${widget.professional.commonMeetingTimeFrame} min/patient',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(int queueLength) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard('In Queue', queueLength.toString(), Icons.people, AppColors.primary),
        _buildStatCard('Served', _totalServed.toString(), Icons.check_circle, AppColors.success),
        _buildStatCard('Cancelled', _totalCancelled.toString(), Icons.cancel, AppColors.error),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPatientCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Patient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_currentAppointment!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(_currentAppointment!.mobileNo, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(width: 24),
                  const Icon(Icons.cake, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text('${_currentAppointment!.age} years', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeAppointment(_currentAppointment!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _skipAppointment(_currentAppointment!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Skip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueueSection(List<AppointmentModel> queueList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Queue List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${queueList.length} total', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        if (queueList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.event_available, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No appointments in queue', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: queueList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final appointment = queueList[index];
              final isInProgress = appointment.appointmentId == _currentAppointment?.appointmentId;
              final position = index + 1;
              return _buildQueueItem(appointment, position, isInProgress, queueList);
            },
          ),
      ],
    );
  }

  Widget _buildQueueItem(AppointmentModel appointment, int position, bool isInProgress, List<AppointmentModel> queueList) {
    return Card(
      elevation: 0,
      color: isInProgress ? AppColors.success.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isInProgress ? AppColors.success : Colors.grey.withOpacity(0.2),
          width: isInProgress ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isInProgress ? AppColors.success : (position == 1 ? AppColors.warning : AppColors.primary.withOpacity(0.1)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                color: isInProgress || position == 1 ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(appointment.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            if (isInProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: Text('IN PROGRESS', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(appointment.appointmentExpectedTime, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(appointment.mobileNo, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'call':
                _callNextPatient(queueList);
                break;
              case 'complete':
                _completeAppointment(appointment);
                break;
              case 'skip':
                _skipAppointment(appointment);
                break;
              case 'cancel':
                _cancelAppointment(appointment);
                break;
            }
          },
          itemBuilder: (context) => [
            if (position == 1 && !isInProgress)
              const PopupMenuItem(value: 'call', child: Row(children: [Icon(Icons.phone_forwarded), SizedBox(width: 12), Text('Call Patient')])),
            if (isInProgress)
              const PopupMenuItem(value: 'complete', child: Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 12), Text('Complete')])),
            const PopupMenuItem(value: 'skip', child: Row(children: [Icon(Icons.skip_next), SizedBox(width: 12), Text('Skip to End')])),
            const PopupMenuItem(value: 'cancel', child: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 12), Text('Cancel', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }
}