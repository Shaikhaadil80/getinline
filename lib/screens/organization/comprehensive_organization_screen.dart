// =============================================================================
// COMPREHENSIVE ORGANIZATION SCREEN
// Complete organization profile with stats, QR, settings, and management
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../providers/professional_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/organization_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/qr_code_widget.dart';
import '../organization/professionals_screen.dart';
import '../organization/joined_users_screen.dart';
import '../organization/analytics_screen.dart';

class ComprehensiveOrganizationScreen extends StatefulWidget {
  const ComprehensiveOrganizationScreen({Key? key}) : super(key: key);

  @override
  State<ComprehensiveOrganizationScreen> createState() => _ComprehensiveOrganizationScreenState();
}

class _ComprehensiveOrganizationScreenState extends State<ComprehensiveOrganizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  OrganizationModel? _organization;
  
  // Stats
  int _totalProfessionals = 0;
  int _activeProfessionals = 0;
  int _totalMembers = 0;
  int _todayAppointments = 0;
  int _totalAppointments = 0;
  int _pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {

    _loadOrganizationData();

    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizationData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);
      final profProvider = Provider.of<ProfessionalProvider>(context, listen: false);
      final aptProvider = Provider.of<AppointmentProvider>(context, listen: false);

      final orgId = authProvider.organizationId;
      if (orgId == null) return;

      // Load organization details
      await orgProvider.getOrganizationById(orgId);
      _organization = orgProvider.currentOrganization;

      // Load stats in parallel
      await Future.wait([
        profProvider.getProfessionalsByOrganization(orgId),
        aptProvider.getOrganizationAppointments(orgId),
        orgProvider.getOrganizationUsers(orgId),
        orgProvider.getJoinRequests(orgId),
      ]);

      setState(() {
        _totalProfessionals = profProvider.professionals.length;
        _activeProfessionals = profProvider.availableProfessionals.length;
        _totalMembers = orgProvider.organizationUsers.length;
        _todayAppointments = aptProvider.appointments
            .where((apt) => DateTimeHelper.isToday(apt.appointmentDate))
            .length;
        _totalAppointments = aptProvider.appointments.length;
        _pendingRequests = orgProvider.joinRequests
            .where((req) => req.isPending)
            .length;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      if (mounted) {
        UIHelper.showSnackBar(context, 'Failed to load organization data', isError: true);
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
          ? const LoadingWidget(message: 'Loading organization...')
          : _organization == null
              ? _buildErrorState()
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      _buildSliverAppBar(innerBoxIsScrolled),
                      _buildSliverTabBar(),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildDetailsTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SLIVER APP BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadOrganizationData,
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 12),
                  Text('Share Organization'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'qr',
              child: Row(
                children: [
                  Icon(Icons.qr_code, size: 20),
                  SizedBox(width: 12),
                  Text('Show QR Code'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Edit Details'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                
                // Organization Logo
                if (_organization!.hasPicture)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      _organization!.picUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultLogo();
                      },
                    ),
                  )
                else
                  _buildDefaultLogo(),
                
                const SizedBox(height: 16),
                
                // Organization Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _organization!.organizationName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _organization!.isActive
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _organization!.isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _organization!.isActive ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: _organization!.isActive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _organization!.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _organization!.isActive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.business,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SLIVER TAB BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Details'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 1: OVERVIEW
  // ═══════════════════════════════════════════════════════════
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadOrganizationData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Stats Grid
          _buildStatsGrid(),
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Professionals',
              '$_activeProfessionals / $_totalProfessionals',
              Icons.medical_services,
              AppColors.primary,
              'Active professionals',
            ),
            _buildStatCard(
              'Team Members',
              '$_totalMembers',
              Icons.group,
              AppColors.accent,
              'Total users',
            ),
            _buildStatCard(
              'Today',
              '$_todayAppointments',
              Icons.event_available,
              AppColors.success,
              'Appointments today',
            ),
            _buildStatCard(
              'Pending',
              '$_pendingRequests',
              Icons.pending_actions,
              AppColors.warning,
              'Join requests',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionChip('Professionals', Icons.medical_services, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalsScreen()));
            }),
            _buildActionChip('Team', Icons.group, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinedUsersScreen()));
            }),
            _buildActionChip('Analytics', Icons.analytics, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
            }),
            _buildActionChip('Show QR', Icons.qr_code, _showQRDialog),
            _buildActionChip('Share', Icons.share, _shareOrganization),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildActivityItem(
                Icons.event,
                'Today\'s Appointments',
                '$_todayAppointments scheduled',
                AppColors.success,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.medical_services,
                'Active Professionals',
                '$_activeProfessionals currently IN',
                AppColors.primary,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.pending,
                'Pending Requests',
                '$_pendingRequests waiting approval',
                AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 2: DETAILS
  // ═══════════════════════════════════════════════════════════
  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoSection(
          'Contact Information',
          Icons.contact_page,
          [
            _buildInfoRow('Mobile', StringHelper.formatMobileNumber(_organization!.mobile), Icons.phone),
            _buildInfoRow('Address', _organization!.address, Icons.location_on),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildInfoSection(
          'Organization Details',
          Icons.business,
          [
            _buildInfoRow('Created', DateTimeHelper.formatDate(_organization!.createdAt), Icons.calendar_today),
            _buildInfoRow('Total Appointments', '$_totalAppointments', Icons.event),
            _buildInfoRow('Professionals', '$_totalProfessionals', Icons.medical_services),
            _buildInfoRow('Team Size', '$_totalMembers members', Icons.group),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_organization!.hasLocation) ...[
          _buildInfoSection(
            'Location',
            Icons.map,
            [
              ElevatedButton.icon(
                onPressed: () {
                  // Open map
                },
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        
        _buildQRSection(),
      ],
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
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
                    fontSize: 16,
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text(
                  'Organization QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            QRCodeDisplay(
              data: _organization!.qrId,
              size: 200,
              title: _organization!.organizationName,
            ),
            const SizedBox(height: 16),
            Text(
              'Scan this QR to join ${_organization!.organizationName}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showQRDialog,
                    icon: const Icon(Icons.fullscreen, size: 18),
                    label: const Text('Fullscreen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareOrganization,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 3: SETTINGS
  // ═══════════════════════════════════════════════════════════
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsSection(
          'Organization',
          [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Details'),
              subtitle: const Text('Update organization information'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                UIHelper.showInfoDialog(context, title: 'Edit Details', message: 'Organization edit screen coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Change Logo'),
              subtitle: const Text('Upload new organization logo'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _changeLogo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildSettingsSection(
          'Management',
          [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Team Members'),
              subtitle: Text('$_totalMembers members'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinedUsersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Professionals'),
              subtitle: Text('$_totalProfessionals professionals'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalsScreen()));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildSettingsSection(
          'Danger Zone',
          [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text('Delete Organization', style: TextStyle(color: AppColors.error)),
              subtitle: const Text('Permanently delete this organization'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.error),
              onTap: _deleteOrganization,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════
  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareOrganization();
        break;
      case 'qr':
        _showQRDialog();
        break;
      case 'edit':
        UIHelper.showInfoDialog(context, title: 'Edit', message: 'Edit screen coming soon');
        break;
    }
  }

  void _showQRDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _organization!.organizationName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              QRCodeDisplay(
                data: _organization!.qrId,
                size: 280,
                title: _organization!.organizationName,
              ),
              const SizedBox(height: 24),
              const Text(
                'Scan to join organization',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareOrganization() {
    Share.share(
      'Join ${_organization!.organizationName} on GetInLine!\n\n'
      'Organization QR: ${_organization!.qrId}\n\n'
      'Download the app to book appointments and join the queue.',
      subject: 'Join ${_organization!.organizationName}',
    );
  }

  void _changeLogo() {
    UIHelper.showInfoDialog(context, title: 'Change Logo', message: 'Image upload coming soon');
  }

  Future<void> _deleteOrganization() async {
    final confirm = await UIHelper.showConfirmationDialog(
      context,
      title: 'Delete Organization',
      message: 'Are you sure you want to permanently delete this organization? This cannot be undone.',
      confirmText: 'Delete',
      isDangerous: true,
    );

    if (confirm && mounted) {
      UIHelper.showSnackBar(context, 'Organization deletion would happen here');
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Organization not found'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

// Tab bar delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
