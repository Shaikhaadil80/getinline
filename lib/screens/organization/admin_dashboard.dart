// =============================================================================
// GETINLINE FLUTTER - screens/organization/admin_dashboard.dart
// Complete Admin Dashboard with Role-Based Features and Analytics
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/screens/auth/organization_login_screen.dart';
import 'package:getinline/screens/organization/comprehensive_organization_screen.dart';
import 'package:getinline/screens/organization/settings_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/professional_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/organization_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'notification_screen.dart';
import 'professionals_screen.dart';
import 'appointment_list_screen.dart';
import 'join_requests_screen.dart';
import 'joined_users_screen.dart';
import '../auth/create_update_profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int _todayAppointments = 0;
  int _activeProfessionals = 0;
  int _pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    // Defer the data loading until after the initial build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final professionalProvider = Provider.of<ProfessionalProvider>(
        context,
        listen: false,
      );
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );
      final organizationProvider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );

      final orgId = authProvider.organizationId;
      if (orgId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load data in parallel
      await Future.wait([
        professionalProvider.getProfessionalsByOrganization(orgId),
        appointmentProvider.getOrganizationAppointments(orgId),
        organizationProvider.getJoinRequests(orgId),
      ]);

      // Calculate statistics
      _activeProfessionals = professionalProvider.availableProfessionals.length;
      _todayAppointments = appointmentProvider.appointments
          .where((apt) => DateTimeHelper.isToday(apt.appointmentDate))
          .length;
      _pendingRequests = organizationProvider.joinRequests
          .where((req) => req.isPending)
          .length;
    } catch (e) {
      print('❌ Error loading dashboard: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Failed to load dashboard data',
          isError: true,
        );
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
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          // Notifications with badge
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_pendingRequests > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _pendingRequests > 9 ? '9+' : '$_pendingRequests',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),

          // Profile Menu
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            icon: const Icon(Icons.more_vert),
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
                value: 'organization',
                child: Row(
                  children: [
                    Icon(Icons.business, size: 20),
                    SizedBox(width: 12),
                    Text('Organization'),
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
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Header
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),

                      // Statistics Cards
                      _buildStatisticsCards(),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: 24),

                      // Today's Overview
                      _buildTodayOverview(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          user?.name ?? 'Admin',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColorHelper.getRoleColor(user?.role ?? '').withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield,
                size: 14,
                color: ColorHelper.getRoleColor(user?.role ?? ''),
              ),
              const SizedBox(width: 6),
              Text(
                StringHelper.capitalize(user?.role ?? 'Admin'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColorHelper.getRoleColor(user?.role ?? ''),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Today\'s\nAppointments',
            _todayAppointments.toString(),
            Icons.calendar_today,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Available\nProfessionals',
            _activeProfessionals.toString(),
            Icons.people,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending\nRequests',
            _pendingRequests.toString(),
            Icons.notification_important,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Professionals',
              Icons.medical_services,
              AppColors.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfessionalsScreen()),
              ),
            ),
            _buildActionCard(
              'Appointments',
              Icons.event,
              AppColors.accent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppointmentListScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Join Requests',
              Icons.group_add,
              AppColors.info,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinRequestsScreen()),
              ),
            ),
            _buildActionCard(
              'Team Members',
              Icons.people,
              AppColors.success,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinedUsersScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
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

  Widget _buildTodayOverview() {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final todayAppts = appointmentProvider.appointments
        .where((apt) => DateTimeHelper.isToday(apt.appointmentDate))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Appointments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (todayAppts.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppointmentListScreen(),
                  ),
                ),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (todayAppts.isEmpty)
          EmptyStateWidget(
            icon: Icons.event_available,
            title: 'No Appointments Today',
            message: 'There are no appointments scheduled for today.',
            actionLabel: 'Create Appointment',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppointmentListScreen()),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayAppts.length > 5 ? 5 : todayAppts.length,
            itemBuilder: (context, index) {
              final appointment = todayAppts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(
                    appointment.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${appointment.appointmentExpectedTime} • Age: ${appointment.age}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorHelper.getStatusColor(
                        appointment.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColorHelper.getStatusColor(appointment.status),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _handleMenuSelection(String value) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final organizationProvider = Provider.of<OrganizationProvider>(
    //   context,
    //   listen: false,
    // );

    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateUpdateProfileScreen(
              uid: authProvider.currentUser!.uid,
              isCustomer: false,
              isUpdate: true,
            ),
          ),
        );
        break;

      case 'organization':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ComprehensiveOrganizationScreen()),
        );
        // await organizationProvider.getOrganizationById(
        //   authProvider.organizationId ?? 'N/A',
        // );
        // if (organizationProvider.currentOrganization == null) {
        //   return;
        // } else {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => OrganizationDetailsScreen(
        //         organization: organizationProvider.currentOrganization!,
        //       ),
        //     ),
        //   );
        // }
        // UIHelper.showInfoDialog(
        //   context,
        //   title: 'Organization Info',
        //   message: 'Organization details screen coming soon!',
        // );
        break;

      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        // UIHelper.showInfoDialog(
        //   context,
        //   title: 'Settings',
        //   message: 'Settings screen coming soon!',
        // );
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
              MaterialPageRoute(
                builder: (_) => const OrganizationLoginScreen(),
              ),
              (route) => false,
            );
          }
        }
        break;
    }
  }
}
