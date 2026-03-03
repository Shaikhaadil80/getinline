// Bulk Operations Screen
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class BulkOperationsScreen extends StatelessWidget {
  const BulkOperationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Operations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOperationCard(
            'Import Appointments',
            'Upload CSV file to import multiple appointments',
            Icons.file_upload,
            AppColors.primary,
            () {},
          ),
          _buildOperationCard(
            'Export Appointments',
            'Download all appointments as CSV or Excel',
            Icons.file_download,
            AppColors.accent,
            () {},
          ),
          _buildOperationCard(
            'Import Professionals',
            'Upload CSV file to add multiple professionals',
            Icons.upload_file,
            AppColors.success,
            () {},
          ),
          _buildOperationCard(
            'Export Reports',
            'Generate comprehensive PDF reports',
            Icons.description,
            AppColors.info,
            () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildOperationCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
