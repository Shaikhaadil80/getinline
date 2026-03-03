// =============================================================================
// GETINLINE FLUTTER - screens/organization/notification_screen.dart
// Notification Management with Read/Unread Tabs and Auto-Delete
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    await context.read<NotificationProvider>().getUserNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final allNotifications = provider.notifications;
        final unreadNotifications = allNotifications.where((n) => !n.read).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('All'),
                      if (allNotifications.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${allNotifications.length}',
                            style: const TextStyle(fontSize: 12),
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
                      const Text('Unread'),
                      if (unreadNotifications.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${unreadNotifications.length}',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (allNotifications.any((n) => n.read))
                PopupMenuButton<String>(
                  onSelected: (action) => _handleMenuAction(action, provider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete_read',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Row(
                        children: [
                          Icon(Icons.done_all, size: 20),
                          SizedBox(width: 8),
                          Text('Mark All as Read'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: provider.isLoading && allNotifications.isEmpty
              ? const LoadingWidget(message: 'Loading notifications...')
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationList(allNotifications, provider),
                      _buildNotificationList(unreadNotifications, provider, unreadOnly: true),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, NotificationProvider provider, {bool unreadOnly = false}) {
    if (notifications.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.notifications_none,
        title: unreadOnly ? 'No Unread Notifications' : 'No Notifications',
        message: unreadOnly
            ? 'You\'re all caught up!'
            : 'You don\'t have any notifications yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(notifications[index], provider);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
    return Dismissible(
      key: Key(notification.notificationId),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteNotification(notification, provider),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.read ? 0 : 2,
        color: notification.read ? Colors.grey.shade100 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.read ? Colors.grey.shade300 : AppColors.primary.withOpacity(0.3),
            width: notification.read ? 0.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification, provider),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.notificationType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.notificationType),
                    color: _getNotificationColor(notification.notificationType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.read ? FontWeight.w500 : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateTimeHelper.getTimeAgoString(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
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

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'appointment':
        return Icons.event;
      case 'join_request':
        return Icons.group_add;
      case 'professional_status':
        return Icons.medical_services;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'appointment':
        return AppColors.primary;
      case 'join_request':
        return AppColors.success;
      case 'professional_status':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification, NotificationProvider provider) async {
    if (!notification.read) {
      await provider.markAsRead(notification.notificationId);
    }
    // Navigate based on notification type
    // Implementation would go here
  }

  Future<void> _deleteNotification(NotificationModel notification, NotificationProvider provider) async {
    final success = await provider.deleteNotification(notification.notificationId);
    if (success && mounted) {
      UIHelper.showSnackBar(context, 'Notification deleted');
    }
  }

  void _handleMenuAction(String action, NotificationProvider provider) async {
    switch (action) {
      case 'delete_read':
        final confirm = await UIHelper.showConfirmationDialog(
          context,
          title: 'Delete Read Notifications',
          message: 'Are you sure you want to delete all read notifications?',
          confirmText: 'Delete',
          isDangerous: true,
        );

        if (confirm) {
          final success = await provider.deleteReadNotifications();
          if (success && mounted) {
            UIHelper.showSnackBar(context, 'Read notifications deleted');
          }
        }
        break;

      case 'mark_all_read':
        final success = await provider.markAllAsRead();
        if (success && mounted) {
          UIHelper.showSnackBar(context, 'All notifications marked as read');
        }
        break;
    }
  }
}