// =============================================================================
// GETINLINE FLUTTER - screens/organization/analytics_screen.dart
// Advanced Analytics Dashboard with Charts and Reports
// =============================================================================

import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/chart_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Week';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => ['Today', 'Week', 'Month', 'Year']
                .map((period) => PopupMenuItem(value: period, child: Text(period)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_selectedPeriod, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Appointments', '245', Icons.event, AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Completed', '198', Icons.check_circle, AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Cancelled', '32', Icons.cancel, AppColors.error)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Revenue', '₹45,600', Icons.currency_rupee, AppColors.accent)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Appointments Chart
          SimpleBarChart(
            title: 'Appointments by Day',
            data: [
              ChartData('Mon', 35),
              ChartData('Tue', 42),
              ChartData('Wed', 38),
              ChartData('Thu', 45),
              ChartData('Fri', 50),
              ChartData('Sat', 28),
              ChartData('Sun', 15),
            ],
          ),
          const SizedBox(height: 16),
          
          // Professional Performance
          SimpleBarChart(
            title: 'Appointments by Professional',
            data: [
              ChartData('Dr. Smith', 85),
              ChartData('Dr. Jones', 72),
              ChartData('Dr. Davis', 58),
              ChartData('Dr. Wilson', 45),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
