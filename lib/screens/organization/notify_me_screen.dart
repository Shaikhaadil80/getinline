// =============================================================================
// GETINLINE FLUTTER - screens/customer/notify_me_screen.dart
// Professional Availability Notification Subscription
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/professional_provider.dart';
import '../../providers/notify_provider.dart';
import '../../models/professional_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class NotifyMeScreen extends StatefulWidget {
  final String organizationId;

  const NotifyMeScreen({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  State<NotifyMeScreen> createState() => _NotifyMeScreenState();
}

class _NotifyMeScreenState extends State<NotifyMeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();      
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    // Fetch both professionals and user's current subscriptions simultaneously
    final professionalProvider = context.read<ProfessionalProvider>();
    final notifyProvider = context.read<NotifyProvider>();
    
    await Future.wait([
      professionalProvider.getProfessionalsByOrganization(widget.organizationId),
      notifyProvider.getUserNotifies(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify Me'),
      ),
      body: Consumer2<ProfessionalProvider, NotifyProvider>(
        builder: (context, professionalProvider, notifyProvider, child) {
          final isLoading = professionalProvider.isLoading || notifyProvider.isLoading;
          final professionals = professionalProvider.professionals;
          
          // Map user subscriptions to a list of professional IDs for easy checking
          final subscribedProfessionalIds = notifyProvider.notifies
              .map((n) => n.professionalId)
              .toList();

          if (isLoading && professionals.isEmpty) {
            return const LoadingWidget();
          }

          if (professionals.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_off,
              title: 'No Professionals',
              message: 'No professionals available for notifications',
            );
          }

          return Column(
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.info.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Get notified when professionals become available',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Professional List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: professionals.length,
                  itemBuilder: (context, index) {
                    final professional = professionals[index];
                    final isSubscribed = subscribedProfessionalIds.contains(professional.professionalId);
                    
                    return _buildProfessionalCard(professional, isSubscribed, notifyProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfessionalCard(
      ProfessionalModel professional, bool isSubscribed, NotifyProvider notifyProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  backgroundColor: professional.isIn
                      ? AppColors.inStatus.withOpacity(0.1)
                      : AppColors.outStatus.withOpacity(0.1),
                  child: Icon(
                    Icons.medical_services,
                    color: professional.isIn ? AppColors.inStatus : AppColors.outStatus,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        professional.profession,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: professional.isIn ? AppColors.inStatus : AppColors.outStatus,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    professional.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Subscription Toggle
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notify when available',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSubscribed
                            ? 'You will be notified when they\'re IN'
                            : 'Enable to get notifications',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isSubscribed,
                  onChanged: (value) => _handleToggleNotification(professional, value, notifyProvider),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleNotification(
      ProfessionalModel professional, bool enabled, NotifyProvider notifyProvider) async {
    
    if (enabled) {
      final success = await notifyProvider.createNotify(
        professionalId: professional.professionalId,
        organizationId: widget.organizationId,
      );
      if (success && mounted) {
        UIHelper.showSnackBar(context, 'Notifications enabled for ${professional.name}');
      }
    } else {
      try {
        // Find the specific notify record to delete
        final notify = notifyProvider.notifies.firstWhere(
          (n) => n.professionalId == professional.professionalId,
        );
        
        final success = await notifyProvider.deleteNotify(notify.notifyId,professionalId: notify.professionalId);
        if (success && mounted) {
          UIHelper.showSnackBar(context, 'Notifications disabled for ${professional.name}');
        }
      } catch (e) {
        // Fallback in case the item wasn't found locally
        print('Could not find subscription to delete: $e');
      }
    }
  }
}