// =============================================================================
// GETINLINE FLUTTER - screens/customer/my_appointments_screen.dart
// Customer Appointment History with Status Tracking
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/appointment_card.dart';
import 'search_organization_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<AppointmentModel> _allAppointments = [];
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _pastAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
            WidgetsBinding.instance.addPostFrameCallback((_) {
           _loadAppointments();   
    });

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

      final userId = authProvider.currentUser?.uid;
      if (userId == null) return;

      await appointmentProvider.getMyAppointments(userId);

      final now = DateTime.now();
      _allAppointments = appointmentProvider.myAppointments;
      
      _upcomingAppointments = _allAppointments
          .where((apt) => apt.appointmentDate.isAfter(now) || DateTimeHelper.isToday(apt.appointmentDate))
          .toList();
      
      _pastAppointments = _allAppointments
          .where((apt) => apt.appointmentDate.isBefore(now) && !DateTimeHelper.isToday(apt.appointmentDate))
          .toList();

      // Sort by date
      _upcomingAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      _pastAppointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    } catch (e) {
      print('❌ Error loading appointments: $e');
      if (mounted) {
        UIHelper.showSnackBar(context, 'Failed to load appointments', isError: true);
      }
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
        title: const Text('My Appointments'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All'),
                  if (_allAppointments.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_allAppointments.length}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Upcoming'),
                  if (_upcomingAppointments.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_upcomingAppointments.length}',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Past'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading appointments...')
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppointmentList(_allAppointments, 'all'),
                  _buildAppointmentList(_upcomingAppointments, 'upcoming'),
                  _buildAppointmentList(_pastAppointments, 'past'),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchOrganizationScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Appointment'),
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentModel> appointments, String type) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_note,
        title: type == 'all'
            ? 'No Appointments'
            : type == 'upcoming'
                ? 'No Upcoming Appointments'
                : 'No Past Appointments',
        message: type == 'all'
            ? 'Book your first appointment to get started'
            : type == 'upcoming'
                ? 'You don\'t have any upcoming appointments'
                : 'Your past appointments will appear here',
        actionLabel: type == 'all' || type == 'upcoming' ? 'Book Appointment' : null,
        onAction: type == 'all' || type == 'upcoming'
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchOrganizationScreen()),
                );
              }
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(
          appointment: appointment,
          onTap: () {
            // Navigate to appointment details
            UIHelper.showInfoDialog(
              context,
              title: 'Appointment Details',
              message: 'Detailed appointment view coming in next screen!',
            );
          },
          onCancel: appointment.canBeCancelled ? () => _handleCancelAppointment(appointment) : null,
          showActions: true,
        );
      },
    );
  }

  Future<void> _handleCancelAppointment(AppointmentModel appointment) async {
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

      final success = await appointmentProvider.cancelAppointment(
        appointment.appointmentId,
        authProvider.currentUser!.uid,
      );

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        await _loadAppointments();
        UIHelper.showSnackBar(context, 'Appointment cancelled');
      } else {
        UIHelper.showSnackBar(
          context,
          'Failed to cancel appointment',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelper.hideLoadingDialog(context);
        UIHelper.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }
}
