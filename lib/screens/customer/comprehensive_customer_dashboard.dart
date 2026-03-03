// =============================================================================
// COMPREHENSIVE CUSTOMER DASHBOARD
// Complete customer home screen with all features, stats, and quick actions
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/screens/organization/appointment_detail_screen.dart';
import 'package:getinline/screens/organization/my_appointments_screen.dart';
import 'package:getinline/screens/organization/profile_screen.dart';
import 'package:getinline/screens/organization/search_organization_screen.dart';
import 'package:getinline/screens/organization/settings_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/appointment_card.dart';
import '../../models/appointment_model.dart';
// import '../customer/search_organization_screen.dart';
// import '../customer/my_appointments_screen.dart';
// import '../customer/appointment_detail_screen.dart';
// import '../customer/notify_me_screen.dart';
// import '../common/profile_screen.dart';
// import '../common/settings_screen.dart';
import '../auth/user_login_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  // Stats
  int _totalAppointments = 0;
  int _upcomingAppointments = 0;
  int _completedAppointments = 0;
  int _cancelledAppointments = 0;
  List<AppointmentModel> _todayAppointments = [];
  List<AppointmentModel> _nextAppointments = [];
  AppointmentModel? _nextAppointment;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

      final userId = authProvider.currentUser?.uid;
      if (userId == null) return;

      // Load appointments
      await appointmentProvider.getMyAppointments(userId);

      final now = DateTime.now();
      final appointments = appointmentProvider.myAppointments;

      setState(() {
        _totalAppointments = appointments.length;
        
        // Upcoming (future + today)
        _upcomingAppointments = appointments.where((apt) =>
            apt.appointmentDate.isAfter(now) ||
            DateTimeHelper.isToday(apt.appointmentDate)
        ).length;
        
        // Completed
        _completedAppointments = appointments.where((apt) =>
            apt.isCompleted
        ).length;
        
        // Cancelled
        _cancelledAppointments = appointments.where((apt) =>
            apt.isCancelled
        ).length;
        
        // Today's appointments
        _todayAppointments = appointments.where((apt) =>
            DateTimeHelper.isToday(apt.appointmentDate)
        ).toList();
        
        // Next 3 appointments
        final upcoming = appointments.where((apt) =>
            apt.appointmentDate.isAfter(now) ||
            DateTimeHelper.isToday(apt.appointmentDate)
        ).toList();
        upcoming.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
        _nextAppointments = upcoming.take(3).toList();
        
        // Next appointment
        _nextAppointment = upcoming.isNotEmpty ? upcoming.first : null;
      });

    } catch (e) {
      print('❌ Error loading dashboard: $e');
      if (mounted) {
        UIHelper.showSnackBar(context, 'Failed to load dashboard', isError: true);
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
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildGreetingSection(),
                      _buildStatsSection(),
                      _buildQuickActionsSection(),
                      _buildNextAppointmentCard(),
                      _buildUpcomingSection(),
                      _buildRecommendationsSection(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchOrganizationScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Appointment'),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SLIVER APP BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: const Text(
          'GetInLine',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDashboardData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            UIHelper.showInfoDialog(
              context,
              title: 'Notifications',
              message: 'Notification screen coming soon!',
            );
          },
          tooltip: 'Notifications',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 12),
                  Text('My Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help, size: 20),
                  SizedBox(width: 12),
                  Text('Help & Support'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GREETING SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildGreetingSection() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.name ?? 'Guest',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMotivationalMessage(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (_todayAppointments.isNotEmpty) {
      return 'You have ${_todayAppointments.length} appointment${_todayAppointments.length > 1 ? 's' : ''} today';
    }
    if (_nextAppointment != null) {
      final days = _nextAppointment!.appointmentDate.difference(DateTime.now()).inDays;
      if (days == 0) return 'Your appointment is today!';
      if (days == 1) return 'Your appointment is tomorrow';
      return 'Next appointment in $days days';
    }
    return 'Book your next appointment hassle-free!';
  }

  // ═══════════════════════════════════════════════════════════
  // STATS SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '$_totalAppointments',
                  Icons.event,
                  AppColors.primary,
                  'All time',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Upcoming',
                  '$_upcomingAppointments',
                  Icons.event_available,
                  AppColors.success,
                  'Future',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  '$_completedAppointments',
                  Icons.check_circle,
                  AppColors.info,
                  'Done',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Cancelled',
                  '$_cancelledAppointments',
                  Icons.cancel,
                  AppColors.error,
                  'Missed',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // QUICK ACTIONS
  // ═══════════════════════════════════════════════════════════
  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildQuickActionButton(
                'Book',
                Icons.add_circle_outline,
                AppColors.primary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchOrganizationScreen())),
              ),
              _buildQuickActionButton(
                'My Visits',
                Icons.event_note,
                AppColors.accent,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen())),
              ),
              _buildQuickActionButton(
                'Notify',
                Icons.notifications_active,
                AppColors.warning,
                () {
                  // Navigate to notify screen (needs org selection)
                  UIHelper.showInfoDialog(context, title: 'Notifications', message: 'Select an organization first');
                },
              ),
              _buildQuickActionButton(
                'History',
                Icons.history,
                AppColors.info,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NEXT APPOINTMENT CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildNextAppointmentCard() {
    if (_nextAppointment == null) return const SizedBox.shrink();

    final appointment = _nextAppointment!;
    final isToday = DateTimeHelper.isToday(appointment.appointmentDate);
    final daysUntil = appointment.appointmentDate.difference(DateTime.now()).inDays;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Appointment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentDetailScreen(appointmentId: appointment.appointmentId),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isToday ? 'TODAY' : daysUntil == 1 ? 'TOMORROW' : 'IN $daysUntil DAYS',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        appointment.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            DateTimeHelper.formatDate(appointment.appointmentDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            appointment.appointmentExpectedTime,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UPCOMING SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildUpcomingSection() {
    if (_nextAppointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'No Upcoming Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Book your first appointment',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchOrganizationScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._nextAppointments.map((appointment) {
            return AppointmentCard(
              appointment: appointment,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentDetailScreen(appointmentId: appointment.appointmentId),
                  ),
                );
              },
              showActions: true,
            );
          }).toList(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RECOMMENDATIONS SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildRecommendationsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tips & Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            Icons.notifications_active,
            'Enable Notifications',
            'Get notified when professionals become available',
            AppColors.warning,
          ),
          _buildTipCard(
            Icons.access_time,
            'Arrive Early',
            'Arrive 10 minutes before your appointment time',
            AppColors.info,
          ),
          _buildTipCard(
            Icons.qr_code_scanner,
            'Scan QR Code',
            'Quickly join organizations by scanning their QR code',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(IconData icon, String title, String subtitle, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MENU ACTIONS
  // ═══════════════════════════════════════════════════════════
  void _handleMenuSelection(String value) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
        
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
        
      case 'help':
        UIHelper.showInfoDialog(
          context,
          title: 'Help & Support',
          message: 'Help screen coming soon!',
        );
        break;
        
      case 'logout':
        final confirm = await UIHelper.showConfirmationDialog(
          context,
          title: 'Logout',
          message: 'Are you sure you want to logout?',
          confirmText: 'Logout',
          isDangerous: true,
        );
        
        if (confirm && mounted) {
          UIHelper.showLoadingDialog(context, message: 'Logging out...');
          await authProvider.logout();
          
          if (mounted) {
            UIHelper.hideLoadingDialog(context);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const UserLoginScreen()),
              (route) => false,
            );
          }
        }
        break;
    }
  }
}
