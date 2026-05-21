import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../providers/appointment_provider.dart';
import '../../../models/appointment_model.dart';
import '../../../models/professional_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/loading_widget.dart';

// TODO: Import your professional provider if needed
// import '../../../providers/professional_provider.dart'; 

class QueueStatusScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const QueueStatusScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  Timer? _pollingTimer;
  ProfessionalModel? _professional;
  int _myPosition = 0;
  int _estimatedWaitMinutes = 0;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    // Start polling every 15 seconds to mimic real-time updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchQueueData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProfessionalData(),
      _fetchQueueData(),
    ]);
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _loadProfessionalData() async {
    // TODO: Replace with your actual ProfessionalProvider fetch logic
    // final profProvider = context.read<ProfessionalProvider>();
    // _professional = await profProvider.getProfessionalById(widget.appointment.professionalId);
    
    setState(() {
      // Mocking or assigning fetched professional to `_professional`
    });
  }

  Future<void> _fetchQueueData() async {
    if (!mounted) return;
    
    final provider = context.read<AppointmentProvider>();
    await provider.getAppointmentQueue(
      professionalId: widget.appointment.professionalId,
      date: widget.appointment.appointmentDate,
    );

    _calculatePosition(provider.queueAppointments);
  }

  void _calculatePosition(List<AppointmentModel> queueList) {
    if (!mounted) return;

    setState(() {
      _myPosition = queueList.indexWhere((appt) => appt.appointmentId == widget.appointment.appointmentId) + 1;
      
      if (_myPosition > 0 && _professional != null) {
        final peopleAhead = _myPosition - 1;
        _estimatedWaitMinutes = peopleAhead * _professional!.commonMeetingTimeFrame;
      } else {
        _estimatedWaitMinutes = (_myPosition - 1) * 15; // Fallback estimate
      }
    });
  }

  String _getEstimatedTime() {
    if (_estimatedWaitMinutes <= 0) return 'Your turn soon!';
    if (_estimatedWaitMinutes < 60) return 'Approximately $_estimatedWaitMinutes minutes';
    
    final hours = _estimatedWaitMinutes ~/ 60;
    final minutes = _estimatedWaitMinutes % 60;
    return 'Approximately $hours hour${hours > 1 ? 's' : ''}${minutes > 0 ? ' $minutes min' : ''}';
  }

  Color _getStatusColor() {
    if (_myPosition == 1) return AppColors.success;
    if (_myPosition <= 3) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Status'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isInitialLoading = true);
              _fetchQueueData().then((_) => setState(() => _isInitialLoading = false));
            },
          ),
        ],
      ),
      body: _isInitialLoading
          ? const LoadingWidget(message: 'Checking your spot...')
          : RefreshIndicator(
              onRefresh: _fetchQueueData,
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, child) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildProfessionalCard(),
                      if (_professional != null) const SizedBox(height: 16),
                      _buildPositionCard(),
                      const SizedBox(height: 24),
                      _buildAppointmentDetailsCard(),
                      const SizedBox(height: 24),
                      _buildQueueList(provider.queueAppointments),
                      const SizedBox(height: 32),
                      _buildRealTimeIndicator(),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildProfessionalCard() {
    if (_professional == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // CircleAvatar(
            //   radius: 30,
            //   backgroundColor: AppColors.primary.withOpacity(0.1),
            //   backgroundImage: _professional!.profilePicUrl != null ? NetworkImage(_professional!.profilePicUrl!) : null,
            //   child: _professional!.profilePicUrl == null ? Icon(Icons.person, size: 30, color: AppColors.primary) : null,
            // ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_professional!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_professional!.profession, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _professional!.isIn ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _professional!.isIn ? AppColors.success : AppColors.error),
              ),
              child: Text(
                _professional!.status,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _professional!.isIn ? AppColors.success : AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_getStatusColor(), _getStatusColor().withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: _getStatusColor().withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text('Your Position in Queue', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            _myPosition > 0 ? '#$_myPosition' : 'Not in Queue',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 56),
          ),
          const SizedBox(height: 8),
          if (_myPosition > 1)
            Text('${_myPosition - 1} ${_myPosition - 1 == 1 ? 'person' : 'people'} ahead of you', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
          if (_myPosition == 1)
            Text('You\'re next! 🎉', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(_getEstimatedTime(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Appointment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Patient Name', widget.appointment.name, Icons.person),
                const Divider(),
                _buildDetailRow('Date', DateTimeHelper.formatDate(widget.appointment.appointmentDate), Icons.calendar_today),
                const Divider(),
                _buildDetailRow('Expected Time', widget.appointment.appointmentExpectedTime, Icons.access_time),
                const Divider(),
                _buildDetailRow(
                  'Status', 
                  StringHelper.capitalize(widget.appointment.status), 
                  Icons.info_outline,
                  valueColor: widget.appointment.status == 'accepted' || widget.appointment.status == 'inLine' ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(List<AppointmentModel> queueList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Live Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${queueList.length} total', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        if (queueList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.event_available, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('Queue is currently empty', style: TextStyle(color: AppColors.textSecondary)),
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
              final isMyAppointment = appointment.appointmentId == widget.appointment.appointmentId;
              final position = index + 1;

              return Card(
                elevation: 0,
                color: isMyAppointment ? AppColors.primary.withOpacity(0.1) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isMyAppointment ? AppColors.primary : Colors.grey.withOpacity(0.2), width: isMyAppointment ? 2 : 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isMyAppointment ? AppColors.primary : (position == 1 ? AppColors.success : AppColors.primary.withOpacity(0.1)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$position',
                        style: TextStyle(color: isMyAppointment || position == 1 ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  title: Text(
                    isMyAppointment ? 'You' : appointment.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(appointment.appointmentExpectedTime, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  trailing: position == 1
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.success)),
                          child: Text('IN PROGRESS', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRealTimeIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)]),
        ),
        const SizedBox(width: 8),
        Text('Live updating enabled', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}