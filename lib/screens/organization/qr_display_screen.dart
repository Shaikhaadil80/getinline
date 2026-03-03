// QR Display Screen
import 'package:flutter/material.dart';
import '../../widgets/qr_code_widget.dart';
import '../../utils/constants.dart';

class QRDisplayScreen extends StatelessWidget {
  final String qrData;
  final String title;
  const QRDisplayScreen({Key? key, required this.qrData, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title QR Code')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QRCodeDisplay(data: qrData, size: 280, title: title),
              const SizedBox(height: 24),
              Text('Scan this QR code to $title', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
