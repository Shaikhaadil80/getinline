// =============================================================================
// GETINLINE FLUTTER - screens/organization/joined_users_screen.dart
// Team Member Management with Role Updates and User Removal
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/status_badge.dart';

class JoinedUsersScreen extends StatefulWidget {
  const JoinedUsersScreen({Key? key}) : super(key: key);

  @override
  State<JoinedUsersScreen> createState() => _JoinedUsersScreenState();
}

class _JoinedUsersScreenState extends State<JoinedUsersScreen> {
  bool _isLoading = true;
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
            WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadUsers();
    _searchController.addListener(_filterUsers);
          
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

      final orgId = authProvider.organizationId;
      if (orgId == null) return;

      await organizationProvider.getOrganizationUsers(orgId);

      _users = organizationProvider.organizationUsers;
      _filteredUsers = _users;
    } catch (e) {
      print('❌ Error loading users: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Failed to load team members',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          return user.name.toLowerCase().contains(query) ||
                 user.mobile.contains(query) ||
                 user.role.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          if (_users.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUsers,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading team members...')
          : Column(
              children: [
                // Search Bar
                if (_users.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, mobile, or role...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // User List
                Expanded(
                  child: _filteredUsers.isEmpty
                      ? EmptyStateWidget(
                          icon: _searchController.text.isNotEmpty
                              ? Icons.search_off
                              : Icons.people_outline,
                          title: _searchController.text.isNotEmpty
                              ? 'No Results Found'
                              : 'No Team Members',
                          message: _searchController.text.isNotEmpty
                              ? 'Try different search terms'
                              : 'Team members will appear here once they join',
                          actionLabel: _users.isEmpty ? null : 'Clear Search',
                          onAction: _users.isEmpty 
                              ? null 
                              : () => _searchController.clear(),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              return _buildUserCard(_filteredUsers[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final isCurrentUser = user.uid == currentUser?.uid;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ColorHelper.getRoleColor(user.role).withOpacity(0.1),
                  child: Text(
                    StringHelper.getInitials(user.name),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorHelper.getRoleColor(user.role),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isCurrentUser)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'YOU',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        StringHelper.formatMobileNumber(user.mobile),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Role Badge
                RoleBadge(role: user.role),
              ],
            ),

            if (user.address.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.address,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Actions
            if (!isCurrentUser && user.role != AppConstants.roleAdmin) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateRoleDialog(user),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Update Role'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _handleRemoveUser(user),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    child: const Icon(Icons.person_remove, size: 18),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showUpdateRoleDialog(UserModel user) {
    String? selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Update Role for ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.organizationRoles.map((role) {
              return RadioListTile<String>(
                title: Text(StringHelper.capitalize(role)),
                value: role,
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() => selectedRole = value);
                },
                activeColor: AppColors.primary,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedRole != null && selectedRole != user.role) {
                  _handleUpdateRole(user, selectedRole!);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdateRole(UserModel user, String newRole) async {
    UIHelper.showLoadingDialog(context, message: 'Updating role...');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

      final success = await organizationProvider.updateUserRole(
        userId: user.uid,
        role: newRole,
        updatedBy: authProvider.currentUser!.uid,
      );

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        await _loadUsers();
        UIHelper.showSnackBar(context, 'Role updated successfully');
      } else {
        UIHelper.showSnackBar(
          context,
          'Failed to update role',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Update role error: $e');
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

  Future<void> _handleRemoveUser(UserModel user) async {
    final confirm = await UIHelper.showConfirmationDialog(
      context,
      title: 'Remove User',
      message: 'Are you sure you want to remove ${user.name} from the organization?',
      confirmText: 'Remove',
      isDangerous: true,
    );

    if (!confirm) return;

    UIHelper.showLoadingDialog(context, message: 'Removing user...');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

      final success = await organizationProvider.removeUserFromOrganization(
        userId: user.uid,
        organizationId: authProvider.organizationId!,
      );

      if (!mounted) return;
      UIHelper.hideLoadingDialog(context);

      if (success) {
        await _loadUsers();
        UIHelper.showSnackBar(context, 'User removed successfully');
      } else {
        UIHelper.showSnackBar(
          context,
          'Failed to remove user',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Remove user error: $e');
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
