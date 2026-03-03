// =============================================================================
// GETINLINE FLUTTER - screens/common/terms_screen.dart
// Terms and Conditions Screen
// =============================================================================

import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
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
              'Acceptance of Terms',
              'By accessing and using GetInLine, you accept and agree to be bound by the '
              'terms and provision of this agreement.',
            ),
            
            _buildSection(
              'Use License',
              'Permission is granted to temporarily use GetInLine for personal or commercial use. '
              'This license shall automatically terminate if you violate any of these restrictions.',
            ),
            
            _buildSection(
              'User Accounts',
              'You are responsible for:\n\n'
              '• Maintaining the confidentiality of your account\n'
              '• All activities that occur under your account\n'
              '• Notifying us of unauthorized use\n'
              '• Providing accurate information',
            ),
            
            _buildSection(
              'Appointment Booking',
              '• Appointments are subject to availability\n'
              '• Maximum 3 appointments per day per customer\n'
              '• Cancellation policies apply\n'
              '• Payment terms must be followed',
            ),
            
            _buildSection(
              'Prohibited Activities',
              'You may not:\n\n'
              '• Use the service for illegal purposes\n'
              '• Attempt to gain unauthorized access\n'
              '• Interfere with service operation\n'
              '• Impersonate others\n'
              '• Transmit harmful code',
            ),
            
            _buildSection(
              'Limitation of Liability',
              'GetInLine shall not be liable for any indirect, incidental, special, consequential, '
              'or punitive damages resulting from your use of the service.',
            ),
            
            _buildSection(
              'Changes to Terms',
              'We reserve the right to modify these terms at any time. Continued use of the '
              'service after changes constitutes acceptance of the modified terms.',
            ),
            
            _buildSection(
              'Contact Information',
              'For questions about these Terms, contact us at:\n\n'
              'Email: legal@getinline.com\n'
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
