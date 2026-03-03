// =============================================================================
// GETINLINE FLUTTER - widgets/appointment_card.dart
// Reusable Appointment Card Widget with Status Indicators
// =============================================================================

import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final bool showActions;
  final bool showQueuePosition;
  final int? queuePosition;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
    this.onCancel,
    this.showActions = false,
    this.showQueuePosition = false,
    this.queuePosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Status
              Row(
                children: [
                  // Patient Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and Age
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Age: ${appointment.age}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  _buildStatusBadge(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              const Divider(height: 1),
              
              const SizedBox(height: 12),
              
              // Details
              _buildDetailRow(
                Icons.phone,
                'Mobile',
                StringHelper.formatMobileNumber(appointment.mobileNo),
              ),
              
              const SizedBox(height: 8),
              
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                DateTimeHelper.formatDate(appointment.appointmentDate),
              ),
              
              if (appointment.appointmentExpectedTime.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.access_time,
                  'Expected Time',
                  appointment.appointmentExpectedTime,
                ),
              ],
              
              if (showQueuePosition && queuePosition != null) ...[
                const SizedBox(height: 8),
                _buildQueuePosition(queuePosition!),
              ],
              
              if (appointment.address.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.location_on,
                  'Address',
                  StringHelper.truncate(appointment.address, 50),
                ),
              ],
              
              // Actions
              if (showActions && appointment.canBeCancelled) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onCancel != null)
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (onTap != null)
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    switch (appointment.status.toLowerCase()) {
      case 'accepted':
        color = AppColors.acceptedStatus;
        text = 'Accepted';
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = AppColors.pendingStatus;
        text = 'Pending';
        icon = Icons.pending;
        break;
      case 'cancelled':
        color = AppColors.cancelledStatus;
        text = 'Cancelled';
        icon = Icons.cancel;
        break;
      case 'inline':
        color = AppColors.inLineStatus;
        text = 'In Queue';
        icon = Icons.schedule;
        break;
      default:
        color = AppColors.textSecondary;
        text = appointment.status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQueuePosition(int position) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Queue Position',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  position == 1 
                      ? 'Your turn next!' 
                      : '$position ${position == 2 ? 'person' : 'people'} ahead',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPACT APPOINTMENT CARD
// =============================================================================

class CompactAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;

  const CompactAppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(
          appointment.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${DateTimeHelper.formatDate(appointment.appointmentDate)} • ${appointment.appointmentExpectedTime}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: _buildCompactStatus(),
      ),
    );
  }

  Widget _buildCompactStatus() {
    Color color = ColorHelper.getStatusColor(appointment.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        appointment.status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
