// =============================================================================
// GETINLINE FLUTTER - widgets/user_card.dart
// Reusable User Card Widget with Role Badge
// =============================================================================

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'status_badge.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final bool showRole;
  final bool showAddress;
  final bool showFullDetails;
  final Widget? trailing;
  final bool isCurrentUser;

  const UserCard({
    Key? key,
    required this.user,
    this.onTap,
    this.showRole = true,
    this.showAddress = false,
    this.showFullDetails = false,
    this.trailing,
    this.isCurrentUser = false,
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
        Row(
          children: [
            _buildAvatar(40),
            const SizedBox(width: 16),
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
                            fontSize: 18,
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showRole) RoleBadge(role: user.role),
          ],
        ),
        if (showAddress && user.address.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (trailing != null) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildCompactCard() {
    return Row(
      children: [
        _buildAvatar(45),
        const SizedBox(width: 12),
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentUser)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'YOU',
                        style: TextStyle(
                          fontSize: 9,
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
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (showRole)
          RoleBadge(role: user.role)
        else if (trailing != null)
          trailing!
        else
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildAvatar(double radius) {
    return CircleAvatar(
      radius: radius / 2,
      backgroundColor: ColorHelper.getRoleColor(user.role).withOpacity(0.1),
      child: Text(
        StringHelper.getInitials(user.name),
        style: TextStyle(
          fontSize: radius / 2.5,
          fontWeight: FontWeight.bold,
          color: ColorHelper.getRoleColor(user.role),
        ),
      ),
    );
  }
}

// Compact variant
class CompactUserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final bool showRole;

  const CompactUserCard({
    Key? key,
    required this.user,
    this.onTap,
    this.showRole = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserCard(
      user: user,
      onTap: onTap,
      showRole: showRole,
      showFullDetails: false,
    );
  }
}
