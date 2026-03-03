// =============================================================================
// GETINLINE FLUTTER - widgets/qr_code_widget.dart
// QR Code Display and Scanner Widgets
// =============================================================================

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/constants.dart';

class QRCodeDisplay extends StatelessWidget {
  final String data;
  final double size;
  final String? title;

  const QRCodeDisplay({
    Key? key,
    required this.data,
    this.size = 200,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class QRCodeScanner extends StatefulWidget {
  final Function(String) onScanComplete;
  final String? title;

  const QRCodeScanner({
    Key? key,
    required this.onScanComplete,
    this.title,
  }) : super(key: key);

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.title != null) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        Expanded(
          child: MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (isScanning && barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() => isScanning = false);
                  controller.stop();
                  widget.onScanComplete(code);
                }
              }
            },
            overlayBuilder: (context, arguments) {
              return _QrScannerOverlay(
                borderColor: AppColors.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black87,
          child: const Text(
            'Align QR code within the frame',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// Custom overlay to replicate the original QrScannerOverlayShape
class _QrScannerOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  const _QrScannerOverlay({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background (scrim)
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        // Cut-out area (transparent)
        Center(
          child: Container(
            width: cutOutSize,
            height: cutOutSize,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
        // Corner markers
        Center(
          child: SizedBox(
            width: cutOutSize,
            height: cutOutSize,
            child: CustomPaint(
              painter: _CornerPainter(
                borderColor: borderColor,
                borderRadius: borderRadius,
                borderLength: borderLength,
                borderWidth: borderWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints the four corner markers
class _CornerPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;

  _CornerPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Top-left corner
    canvas.drawPath(
      _createCornerPath(
        startX: 0,
        startY: 0,
        horizontal: borderLength,
        vertical: borderLength,
        radius: borderRadius,
        isTopLeft: true,
        isBottomLeft: false,
        isBottomRight: false,
        isTopRight: false,
      ),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      _createCornerPath(
        startX: size.width,
        startY: 0,
        horizontal: -borderLength,
        vertical: borderLength,
        radius: borderRadius,
        isTopRight: true,
        isBottomLeft: false,
        isBottomRight: false,
        isTopLeft: false,
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      _createCornerPath(
        startX: 0,
        startY: size.height,
        horizontal: borderLength,
        vertical: -borderLength,
        radius: borderRadius,
        isBottomLeft: true,
        isBottomRight: false,
        isTopRight: false,
        isTopLeft: false
      ),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      _createCornerPath(
        startX: size.width,
        startY: size.height,
        horizontal: -borderLength,
        vertical: -borderLength,
        radius: borderRadius,
        isBottomRight: true,
        isBottomLeft: false,
        isTopRight: false,
        isTopLeft: false
      ),
      paint,
    );
  }

  Path _createCornerPath({
    required double startX,
    required double startY,
    required double horizontal,
    required double vertical,
    required double radius,
    required bool isTopLeft,
    required bool isTopRight,
    required bool isBottomLeft,
    required bool isBottomRight,
  }) {
    final path = Path();
    path.moveTo(startX, startY);
    path.lineTo(startX + horizontal, startY);
    if (isTopLeft || isBottomLeft) {
      path.arcToPoint(
        Offset(startX, startY + vertical),
        radius: Radius.circular(radius),
        clockwise: isTopLeft,
      );
    } else {
      path.lineTo(startX, startY + vertical);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}