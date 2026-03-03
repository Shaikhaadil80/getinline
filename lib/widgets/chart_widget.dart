// Chart Widget for Analytics
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SimpleBarChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;

  const SimpleBarChart({Key? key, required this.data, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...data.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(width: 80, child: Text(item.label)),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(height: 24, color: Colors.grey.shade200),
                        FractionallySizedBox(
                          widthFactor: item.value / maxValue,
                          child: Container(height: 24, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${item.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  ChartData(this.label, this.value);
}
