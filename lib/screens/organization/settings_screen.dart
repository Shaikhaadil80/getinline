// Settings Screen
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection('Notifications', [
            SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Push Notifications')),
            SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Appointment Reminders')),
          ]),
          _buildSection('Preferences', [
            ListTile(title: const Text('Language'), trailing: const Text('English')),
            ListTile(title: const Text('Theme'), trailing: const Text('Light')),
          ]),
          _buildSection('About', [
            ListTile(title: const Text('Version'), trailing: Text(AppConstants.appVersion)),
            ListTile(title: const Text('Privacy Policy'), trailing: const Icon(Icons.arrow_forward_ios, size: 16)),
            ListTile(title: const Text('Terms & Conditions'), trailing: const Icon(Icons.arrow_forward_ios, size: 16)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
