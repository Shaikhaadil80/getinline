// // =============================================================================
// // GETINLINE FLUTTER - screens/organization/notification_screen.dart
// // Notification Management with Read/Unread Tabs and Auto-Delete
// // =============================================================================

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../models/notification_model.dart';
// import '../../utils/constants.dart';
// import '../../utils/helpers.dart';
// import '../../widgets/loading_widget.dart';
// import '../../widgets/empty_state_widget.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({Key? key}) : super(key: key);

//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<NotificationModel> _allNotifications = [];
//   List<NotificationModel> _unreadNotifications = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _loadNotifications();
//     });

//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadNotifications() async {
//     setState(() => _isLoading = true);

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final userId = authProvider.currentUser?.uid;
      
//       if (userId == null) return;

//       // Mock notifications - In real app, fetch from API
//       await Future.delayed(const Duration(seconds: 1));
      
//       _allNotifications = [
//         NotificationModel(
//           notificationId: '1',
//           userId: userId,
//           title: 'Join Request Accepted',
//           body: 'Your join request has been accepted by Admin',
//           read: false,
//           createdAt: DateTime.now().subtract(const Duration(hours: 1)),
//           data: {'type': 'join_request', 'status': 'accepted'},
//         ),
//         NotificationModel(
//           notificationId: '2',
//           userId: userId,
//           title: 'New Appointment',
//           body: 'A new appointment has been created for Dr. Smith',
//           read: false,
//           createdAt: DateTime.now().subtract(const Duration(hours: 3)),
//           data: {'type': 'appointment', 'appointmentId': 'apt123'},
//         ),
//         NotificationModel(
//           notificationId: '3',
//           userId: userId,
//           title: 'Professional Status Changed',
//           body: 'Dr. Smith is now IN',
//           read: true,
//           createdAt: DateTime.now().subtract(const Duration(days: 1)),
//           data: {'type': 'professional_status', 'professionalId': 'prof123'},
//         ),
//       ];

//       _unreadNotifications = _allNotifications.where((n) => !n.read).toList();
//     } catch (e) {
//       print('❌ Error loading notifications: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text('All'),
//                   if (_allNotifications.isNotEmpty) ...[
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         '${_allNotifications.length}',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Tab(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text('Unread'),
//                   if (_unreadNotifications.isNotEmpty) ...[
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: AppColors.error,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         '${_unreadNotifications.length}',
//                         style: const TextStyle(fontSize: 12, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           if (_allNotifications.any((n) => n.read))
//             PopupMenuButton<String>(
//               onSelected: _handleMenuAction,
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'delete_read',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete_sweep, size: 20),
//                       SizedBox(width: 8),
//                       Text('Delete Read'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'mark_all_read',
//                   child: Row(
//                     children: [
//                       Icon(Icons.done_all, size: 20),
//                       SizedBox(width: 8),
//                       Text('Mark All as Read'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const LoadingWidget(message: 'Loading notifications...')
//           : RefreshIndicator(
//               onRefresh: _loadNotifications,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildNotificationList(_allNotifications),
//                   _buildNotificationList(_unreadNotifications, unreadOnly: true),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildNotificationList(List<NotificationModel> notifications, {bool unreadOnly = false}) {
//     if (notifications.isEmpty) {
//       return EmptyStateWidget(
//         icon: Icons.notifications_none,
//         title: unreadOnly ? 'No Unread Notifications' : 'No Notifications',
//         message: unreadOnly
//             ? 'You\'re all caught up!'
//             : 'You don\'t have any notifications yet.',
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         return _buildNotificationCard(notifications[index]);
//       },
//     );
//   }

//   Widget _buildNotificationCard(NotificationModel notification) {
//     return Dismissible(
//       key: Key(notification.notificationId),
//       background: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: AppColors.error,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) => _deleteNotification(notification),
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 12),
//         elevation: notification.read ? 0 : 2,
//         color: notification.read 
//             ? Colors.grey.shade100 
//             : Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(
//             color: notification.read 
//                 ? Colors.grey.shade300 
//                 : AppColors.primary.withOpacity(0.3),
//             width: notification.read ? 0.5 : 1,
//           ),
//         ),
//         child: InkWell(
//           onTap: () => _handleNotificationTap(notification),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Icon
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: _getNotificationColor(notification.notificationType).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     _getNotificationIcon(notification.notificationType),
//                     color: _getNotificationColor(notification.notificationType),
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//                 // Content
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               notification.title,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: notification.read 
//                                     ? FontWeight.w500 
//                                     : FontWeight.bold,
//                                 color: AppColors.textPrimary,
//                               ),
//                             ),
//                           ),
//                           if (!notification.read)
//                             Container(
//                               width: 8,
//                               height: 8,
//                               decoration: const BoxDecoration(
//                                 color: AppColors.primary,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         notification.body,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         DateTimeHelper.getTimeAgoString(notification.createdAt),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary.withOpacity(0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getNotificationIcon(String? type) {
//     switch (type) {
//       case 'appointment':
//         return Icons.event;
//       case 'join_request':
//         return Icons.group_add;
//       case 'professional_status':
//         return Icons.medical_services;
//       default:
//         return Icons.notifications;
//     }
//   }

//   Color _getNotificationColor(String? type) {
//     switch (type) {
//       case 'appointment':
//         return AppColors.primary;
//       case 'join_request':
//         return AppColors.success;
//       case 'professional_status':
//         return AppColors.warning;
//       default:
//         return AppColors.info;
//     }
//   }

//   void _handleNotificationTap(NotificationModel notification) {
//     if (!notification.read) {
//       setState(() {
//         final index = _allNotifications.indexWhere(
//           (n) => n.notificationId == notification.notificationId,
//         );
//         if (index != -1) {
//           _allNotifications[index] = notification.markAsRead();
//         }
//         _unreadNotifications.removeWhere(
//           (n) => n.notificationId == notification.notificationId,
//         );
//       });

//       // In real app, mark as read on server
//     }

//     // Navigate based on notification type
//     // Implementation would go here
//   }

//   void _deleteNotification(NotificationModel notification) {
//     setState(() {
//       _allNotifications.removeWhere(
//         (n) => n.notificationId == notification.notificationId,
//       );
//       _unreadNotifications.removeWhere(
//         (n) => n.notificationId == notification.notificationId,
//       );
//     });

//     UIHelper.showSnackBar(context, 'Notification deleted');
    
//     // In real app, delete on server
//   }

//   void _handleMenuAction(String action) async {
//     switch (action) {
//       case 'delete_read':
//         final confirm = await UIHelper.showConfirmationDialog(
//           context,
//           title: 'Delete Read Notifications',
//           message: 'Are you sure you want to delete all read notifications?',
//           confirmText: 'Delete',
//           isDangerous: true,
//         );

//         if (confirm) {
//           setState(() {
//             _allNotifications.removeWhere((n) => n.read);
//           });
//           UIHelper.showSnackBar(context, 'Read notifications deleted');
//         }
//         break;

//       case 'mark_all_read':
//         setState(() {
//           _allNotifications = _allNotifications.map((n) => n.markAsRead()).toList();
//           _unreadNotifications.clear();
//         });
//         UIHelper.showSnackBar(context, 'All notifications marked as read');
//         break;
//     }
//   }
// }
