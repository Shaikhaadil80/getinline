// =============================================================================
// GETINLINE FLUTTER - widgets/professional_card.dart
// Reusable Professional Card Widget with IN/OUT Status
// =============================================================================

import 'package:flutter/material.dart';
import '../models/professional_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ProfessionalCard extends StatelessWidget {
  final ProfessionalModel professional;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onStatusToggle;
  final bool showStatusToggle;
  final bool showFullDetails;

  const ProfessionalCard({
    Key? key,
    required this.professional,
    this.onTap,
    this.onLongPress,
    this.onStatusToggle,
    this.showStatusToggle = false,
    this.showFullDetails = true,
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
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name, Profession and Status
              Row(
                children: [
                  // Professional Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: professional.isIn 
                          ? AppColors.inStatus.withOpacity(0.1)
                          : AppColors.outStatus.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getProfessionIcon(),
                      color: professional.isIn 
                          ? AppColors.inStatus 
                          : AppColors.outStatus,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and Profession
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          professional.profession,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Indicator
                  _buildStatusIndicator(),
                ],
              ),
              
              if (showFullDetails) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Degree
                _buildInfoRow(Icons.school, 'Degree', professional.degree),
                
                const SizedBox(height: 8),
                
                // Mobile
                _buildInfoRow(
                  Icons.phone,
                  'Mobile',
                  StringHelper.formatMobileNumber(professional.mobile),
                ),
                
                // Appointment Info
                if (professional.isPaidAppointment) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.payment,
                    'Appointment Fee',
                    StringHelper.formatCurrency(professional.appointmentFees),
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Meeting Time
                _buildInfoRow(
                  Icons.timer,
                  'Meeting Duration',
                  '${professional.commonMeetingTimeFrame} minutes',
                ),
                
                // Time Slots
                if (professional.hasSlots) ...[
                  const SizedBox(height: 12),
                  _buildTimeSlots(),
                ],
                
                // Common Leaves
                if (professional.commonLeaves.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCommonLeaves(),
                ],
                
                // Status Note
                if (professional.inOutNote != null && 
                    professional.inOutNote!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildStatusNote(),
                ],
              ],
              
              // Status Toggle Button
              if (showStatusToggle && onStatusToggle != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStatusToggle,
                    icon: Icon(professional.isIn ? Icons.logout : Icons.login),
                    label: Text(
                      professional.isIn ? 'Mark as OUT' : 'Mark as IN',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: professional.isIn 
                          ? AppColors.error 
                          : AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProfessionIcon() {
    switch (professional.profession.toLowerCase()) {
      case 'doctor':
      case 'physician':
      case 'surgeon':
        return Icons.medical_services;
      case 'dentist':
        return Icons.medical_information;
      case 'lawyer':
      case 'advocate':
        return Icons.gavel;
      case 'engineer':
        return Icons.engineering;
      case 'therapist':
      case 'psychologist':
        return Icons.psychology;
      case 'accountant':
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: professional.isIn 
            ? AppColors.inStatus 
            : AppColors.outStatus,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (professional.isIn 
                ? AppColors.inStatus 
                : AppColors.outStatus).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            professional.status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              'Available Time Slots:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: professional.slots.map((slot) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                slot.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommonLeaves() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.event_busy, size: 18, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              'Weekly Offs:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: professional.commonLeaves.map((day) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, 
              size: 20, 
              color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Note:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  professional.inOutNote!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPACT PROFESSIONAL CARD
// =============================================================================

class CompactProfessionalCard extends StatelessWidget {
  final ProfessionalModel professional;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CompactProfessionalCard({
    Key? key,
    required this.professional,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: professional.isIn 
              ? AppColors.inStatus.withOpacity(0.1)
              : AppColors.outStatus.withOpacity(0.1),
          child: Icon(
            Icons.medical_services,
            color: professional.isIn 
                ? AppColors.inStatus 
                : AppColors.outStatus,
          ),
        ),
        title: Text(
          professional.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          professional.profession,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: professional.isIn 
                ? AppColors.inStatus 
                : AppColors.outStatus,
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
      ),
    );
  }
}
