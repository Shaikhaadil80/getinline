// Help Screen
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpCard('How to book an appointment?', 'Search for organizations, select a professional, choose a date, and confirm your booking.', Icons.help_outline),
          _buildHelpCard('How to cancel?', 'Go to My Appointments, select the appointment, and tap Cancel button.', Icons.cancel_outlined),
          _buildHelpCard('Queue tracking', 'Check your appointment details to see your queue position and expected time.', Icons.queue),
          _buildHelpCard('Contact Support', 'Email: support@getinline.com\nPhone: +91 1234567890', Icons.support_agent),
        ],
      ),
    );
  }

  Widget _buildHelpCard(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(content, style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
