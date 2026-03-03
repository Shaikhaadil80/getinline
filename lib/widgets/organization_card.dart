// =============================================================================
// GETINLINE FLUTTER - widgets/organization_card.dart
// Reusable Organization Card Widget
// =============================================================================

import 'package:flutter/material.dart';
import '../models/organization_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class OrganizationCard extends StatelessWidget {
  final OrganizationModel organization;
  final VoidCallback? onTap;
  final bool showFullDetails;
  final Widget? trailing;

  const OrganizationCard({
    Key? key,
    required this.organization,
    this.onTap,
    this.showFullDetails = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: showFullDetails ? _buildFullCard() : _buildCompactCard(),
        ),
      ),
    );
  }

  Widget _buildFullCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with logo
        Row(
          children: [
            _buildLogo(60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization.organizationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // Details
        _buildDetailRow(
          Icons.phone,
          StringHelper.formatMobileNumber(organization.mobile),
        ),
        const SizedBox(height: 8),
        _buildDetailRow(Icons.location_on, organization.address),
        
        if (organization.hasLocation) ...[
          const SizedBox(height: 8),
          _buildDetailRow(Icons.map, 'View on Map'),
        ],
      ],
    );
  }

  Widget _buildCompactCard() {
    return Row(
      children: [
        _buildLogo(50),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organization.organizationName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                StringHelper.formatMobileNumber(organization.mobile),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: organization.hasPicture
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                organization.picUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.business, color: AppColors.primary);
                },
              ),
            )
          : const Icon(Icons.business, color: AppColors.primary),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: organization.isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        organization.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: organization.isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// Compact variant
class CompactOrganizationCard extends StatelessWidget {
  final OrganizationModel organization;
  final VoidCallback? onTap;

  const CompactOrganizationCard({
    Key? key,
    required this.organization,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrganizationCard(
      organization: organization,
      onTap: onTap,
      showFullDetails: false,
    );
  }
}
