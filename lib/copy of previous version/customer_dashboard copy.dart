// // =============================================================================
// // GETINLINE FLUTTER - screens/customer/customer_dashboard.dart
// // Complete Customer Dashboard with Appointments and Quick Actions
// // =============================================================================

// import 'package:flutter/material.dart';
// import 'package:getinline/screens/organization/my_appointments_screen.dart';
// import 'package:getinline/screens/organization/search_organization_screen.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/appointment_provider.dart';
// import '../../models/appointment_model.dart';
// import '../../utils/constants.dart';
// import '../../utils/helpers.dart';
// import '../../widgets/loading_widget.dart';
// import '../../widgets/empty_state_widget.dart';
// import '../../widgets/appointment_card.dart';
// import '../auth/user_login_screen.dart';
// import '../auth/create_update_profile_screen.dart';

// class CustomerDashboard extends StatefulWidget {
//   const CustomerDashboard({Key? key}) : super(key: key);

//   @override
//   State<CustomerDashboard> createState() => _CustomerDashboardState();
// }

// class _CustomerDashboardState extends State<CustomerDashboard> {
//   bool _isLoading = true;
//   List<AppointmentModel> _upcomingAppointments = [];

//   @override
//   void initState() {
//     super.initState();
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//     _loadData();
//     });
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

//       final userId = authProvider.currentUser?.uid;
//       if (userId == null) return;

//       await appointmentProvider.getMyAppointments(userId);

//       final now = DateTime.now();
//       _upcomingAppointments = appointmentProvider.myAppointments
//           .where((apt) => 
//               apt.appointmentDate.isAfter(now) || 
//               DateTimeHelper.isToday(apt.appointmentDate))
//           .toList();

//       _upcomingAppointments.sort((a, b) => 
//           a.appointmentDate.compareTo(b.appointmentDate));
//     } catch (e) {
//       print('❌ Error loading data: $e');
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
//         title: const Text('GetInLine'),
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {
//               UIHelper.showInfoDialog(
//                 context,
//                 title: 'Notifications',
//                 message: 'Notification screen coming soon!',
//               );
//             },
//           ),
//           PopupMenuButton<String>(
//             onSelected: _handleMenuSelection,
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'profile',
//                 child: Row(
//                   children: [
//                     Icon(Icons.person, size: 20),
//                     SizedBox(width: 12),
//                     Text('My Profile'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'settings',
//                 child: Row(
//                   children: [
//                     Icon(Icons.settings, size: 20),
//                     SizedBox(width: 12),
//                     Text('Settings'),
//                   ],
//                 ),
//               ),
//               const PopupMenuDivider(),
//               const PopupMenuItem(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, size: 20, color: AppColors.error),
//                     SizedBox(width: 12),
//                     Text('Logout', style: TextStyle(color: AppColors.error)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const LoadingWidget()
//           : RefreshIndicator(
//               onRefresh: _loadData,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Welcome Header
//                     _buildWelcomeHeader(),

//                     // Quick Actions
//                     _buildQuickActions(),

//                     // Upcoming Appointments
//                     _buildUpcomingSection(),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildWelcomeHeader() {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary,
//             AppColors.primary.withOpacity(0.8),
//           ],
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Hello,',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             user?.name ?? 'Guest',
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.event_available, size: 16, color: Colors.white),
//                 const SizedBox(width: 6),
//                 Text(
//                   '${_upcomingAppointments.length} upcoming',
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Quick Actions',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildActionCard(
//                   'Book\nAppointment',
//                   Icons.add_circle_outline,
//                   AppColors.primary,
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const SearchOrganizationScreen()),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildActionCard(
//                   'My\nAppointments',
//                   Icons.event_note,
//                   AppColors.accent,
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 40, color: color),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUpcomingSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Upcoming Appointments',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               if (_upcomingAppointments.isNotEmpty)
//                 TextButton(
//                   onPressed: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()),
//                   ),
//                   child: const Text('View All'),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _upcomingAppointments.isEmpty
//               ? EmptyStateWidget(
//                   icon: Icons.event_available,
//                   title: 'No Upcoming Appointments',
//                   message: 'Book your first appointment to get started',
//                   actionLabel: 'Book Now',
//                   onAction: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const SearchOrganizationScreen()),
//                   ),
//                 )
//               : Column(
//                   children: _upcomingAppointments.take(3).map((appointment) {
//                     return AppointmentCard(
//                       appointment: appointment,
//                       onTap: () {
//                         UIHelper.showInfoDialog(
//                           context,
//                           title: 'Appointment Details',
//                           message: 'Detailed view screen coming in 6B!',
//                         );
//                       },
//                       showActions: true,
//                     );
//                   }).toList(),
//                 ),
//         ],
//       ),
//     );
//   }

//   void _handleMenuSelection(String value) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
//     switch (value) {
//       case 'profile':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CreateUpdateProfileScreen(
//               uid: authProvider.currentUser!.uid,
//               isCustomer: true,
//               isUpdate: true,
//             ),
//           ),
//         );
//         break;
        
//       case 'settings':
//         UIHelper.showInfoDialog(
//           context,
//           title: 'Settings',
//           message: 'Settings screen coming soon!',
//         );
//         break;
        
//       case 'logout':
//         final confirm = await UIHelper.showConfirmationDialog(
//           context,
//           title: 'Logout',
//           message: 'Are you sure you want to logout?',
//           confirmText: 'Logout',
//           isDangerous: true,
//         );
        
//         if (confirm && mounted) {
//           UIHelper.showLoadingDialog(context, message: 'Logging out...');
//           await authProvider.logout();
          
//           if (mounted) {
//             UIHelper.hideLoadingDialog(context);
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(builder: (_) => const UserLoginScreen()),
//               (route) => false,
//             );
//           }
//         }
//         break;
//     }
//   }
// }
