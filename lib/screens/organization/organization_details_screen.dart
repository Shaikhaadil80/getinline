// Organization Details Screen - View complete organization information
import 'package:flutter/material.dart';
import 'package:getinline/screens/organization/qr_display_screen.dart';
import '../../models/organization_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class OrganizationDetailsScreen extends StatelessWidget {
  final OrganizationModel organization;
  const OrganizationDetailsScreen({Key? key, required this.organization}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (organization.hasPicture)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(organization.picUrl!, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 24),
            Text(organization.organizationName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInfoCard('Contact', Icons.phone, StringHelper.formatMobileNumber(organization.mobile)),
            _buildInfoCard('Address', Icons.location_on, organization.address),
            if (organization.hasLocation) _buildInfoCard('Location', Icons.map, 'View on Map'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRDisplayScreen(title: organization.organizationName, qrData: organization.qrId)),
                );
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('View QR Code'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
