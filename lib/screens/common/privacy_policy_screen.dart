// =============================================================================
// GETINLINE FLUTTER - screens/common/privacy_policy_screen.dart
// Privacy Policy Screen
// =============================================================================

import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, including:\n\n'
              '• Name and contact information\n'
              '• Account credentials\n'
              '• Appointment details\n'
              '• Payment information\n'
              '• Device and usage information',
            ),
            
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide and improve our services\n'
              '• Process appointments and payments\n'
              '• Send notifications and updates\n'
              '• Ensure security and prevent fraud\n'
              '• Comply with legal obligations',
            ),
            
            _buildSection(
              'Information Sharing',
              'We do not sell your personal information. We may share your information with:\n\n'
              '• Healthcare providers you book appointments with\n'
              '• Service providers who assist our operations\n'
              '• Legal authorities when required by law',
            ),
            
            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your information. '
              'However, no method of transmission over the internet is 100% secure.',
            ),
            
            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '• Access your personal information\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Opt-out of marketing communications',
            ),
            
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@getinline.com\n'
              'Phone: +91 1234567890',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
