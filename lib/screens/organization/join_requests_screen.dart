// =============================================================================
// GETINLINE FLUTTER - screens/organization/join_requests_screen.dart
// Join Request Management with Accept/Reject and Role Assignment
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/join_request_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class JoinRequestsScreen extends StatefulWidget {
  const JoinRequestsScreen({Key? key}) : super(key: key);

  @override
  State<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends State<JoinRequestsScreen> {
  bool _isLoading = true;
  List<JoinRequestModel> _requests = [];
  Map<String, UserModel> _userCache = {};

  @override
  void initState() {
    super.initState();
            WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadJoinRequests();
          
    });
  }

  Future<void> _loadJoinRequests() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

      final orgId = authProvider.organizationId;
      if (orgId == null) return;

      await organizationProvider.getJoinRequests(orgId);

      _requests = organizationProvider.joinRequests
          .where((req) => req.isPending)
          .toList();

      // Load user details for each request
      // In a real app, this would be done via API
      // For now, we'll mock it
      _userCache = {}; // Would fetch user details here
    } catch (e) {
      print('❌ Error loading join requests: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Failed to load join requests',
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
        title: const Text('Join Requests'),
        actions: [
          if (_requests.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadJoinRequests,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading join requests...')
          : _requests.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.inbox,
                  title: 'No Pending Requests',
                  message: 'There are no pending join requests at the moment.',
                  actionLabel: 'Refresh',
                  onAction: _loadJoinRequests,
                )
              : RefreshIndicator(
                  onRefresh: _loadJoinRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(_requests[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildRequestCard(JoinRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID: ${request.userId.substring(0, 8)}...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested ${DateTimeHelper.getTimeAgoString(request.requestedAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Request Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Request Date: ${DateTimeHelper.formatDateTime(request.requestedAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleRejectRequest(request),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptDialog(request),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(JoinRequestModel request) {
    String? selectedRole = AppConstants.roleReceptionist;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Accept Join Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a role for this user:'),
              const SizedBox(height: 16),
              
              // Role Selection
              ...AppConstants.organizationRoles.map((role) {
                return RadioListTile<String>(
                  title: Text(StringHelper.capitalize(role)),
                  subtitle: Text(_getRoleDescription(role)),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setState(() => selectedRole = value);
                  },
                  activeColor: AppColors.primary,
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedRole != null) {
                  _handleAcceptRequest(request, selectedRole!);
                }
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Full access to all features';
      case AppConstants.roleManager:
        return 'Can manage professionals and appointments';
      case AppConstants.roleReceptionist:
        return 'Can create and manage appointments';
      case AppConstants.roleProfessional:
        return 'Can view their appointments';
      default:
        return '';
    }
  }

  Future<void> _handleAcceptRequest(JoinRequestModel request, String role) async {
    UIHelper.showLoadingDialog(context, message: 'Accepting request...');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

      final success = await organizationProvider.acceptJoinRequest(
        requestId: request.requestId,
        role: role,
        handledBy: authProvider.currentUser!.uid,
      );

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        // Remove from local list
        setState(() {
          _requests.removeWhere((r) => r.requestId == request.requestId);
        });

        UIHelper.showSnackBar(
          context,
          'Join request accepted successfully!',
        );

        // In real app, send FCM notification to user here
      } else {
        UIHelper.showSnackBar(
          context,
          organizationProvider.error ?? 'Failed to accept request',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Accept request error: $e');
      if (mounted) {
        UIHelper.hideLoadingDialog(context);
        UIHelper.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Future<void> _handleRejectRequest(JoinRequestModel request) async {
    final confirm = await UIHelper.showConfirmationDialog(
      context,
      title: 'Reject Request',
      message: 'Are you sure you want to reject this join request?',
      confirmText: 'Reject',
      isDangerous: true,
    );

    if (!confirm) return;

    UIHelper.showLoadingDialog(context, message: 'Rejecting request...');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

      final success = await organizationProvider.rejectJoinRequest(
        requestId: request.requestId,
        handledBy: authProvider.currentUser!.uid,
      );

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        // Remove from local list
        setState(() {
          _requests.removeWhere((r) => r.requestId == request.requestId);
        });

        UIHelper.showSnackBar(
          context,
          'Join request rejected',
        );

        // In real app, send FCM notification to user here
      } else {
        UIHelper.showSnackBar(
          context,
          organizationProvider.error ?? 'Failed to reject request',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Reject request error: $e');
      if (mounted) {
        UIHelper.hideLoadingDialog(context);
        UIHelper.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }
}
