// =============================================================================
// GETINLINE FLUTTER - screens/organization/join_organization_screen.dart
// Join Organization via QR Scanner with Complete Validation
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/screens/organization/create_organization_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../models/organization_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import 'admin_dashboard.dart';

class JoinOrganizationScreen extends StatefulWidget {
  const JoinOrganizationScreen({Key? key}) : super(key: key);

  @override
  State<JoinOrganizationScreen> createState() => _JoinOrganizationScreenState();
}

class _JoinOrganizationScreenState extends State<JoinOrganizationScreen> {
  final MobileScannerController controller = MobileScannerController();
  OrganizationModel? scannedOrganization;
  bool isScanning = true;
  bool isLoading = false;
  bool requestSent = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Organization'),
        actions: [
          if (scannedOrganization != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetScan,
              tooltip: 'Scan Again',
            ),
        ],
      ),
      body: scannedOrganization == null
          ? _buildQRScanner()
          : _buildOrganizationDetails(),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withOpacity(0.1),
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Scan Organization QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Point your camera at the QR code provided by the organization',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // QR Scanner
        Expanded(
          flex: 3,
          child: MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            overlayBuilder: (context, arguments) {
              return _QrScannerOverlay(
                borderColor: AppColors.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              );
            },
            errorBuilder: (context, error,) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Camera error: $error'),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Actions
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Align the QR code within the frame',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateOrganizationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_business),
                  label: const Text('Create New Organization'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationDetails() {
    if (isLoading) {
      return const LoadingWidget(message: 'Loading organization details...');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Organization Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Image
                  if (scannedOrganization!.hasPicture) ...[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          scannedOrganization!.picUrl!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              width: 100,
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.business,
                                size: 50,
                                color: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Organization Name
                  Text(
                    scannedOrganization!.organizationName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details
                  _buildDetailRow(
                    Icons.phone,
                    'Mobile',
                    StringHelper.formatMobileNumber(scannedOrganization!.mobile),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.location_on,
                    'Address',
                    scannedOrganization!.address,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Request Status
          if (requestSent)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request Sent!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your join request has been sent to the organization admin. You will be notified once it\'s approved.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Click below to send a join request to this organization. The admin will review and approve your request.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Action Buttons
          if (!requestSent) ...[
            CustomButton(
              text: 'Send Join Request',
              icon: Icons.send,
              onPressed: _handleSendJoinRequest,
              isLoading: isLoading,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Scan Another QR',
              icon: Icons.qr_code_scanner,
              onPressed: _resetScan,
              backgroundColor: Colors.grey,
            ),
          ] else ...[
            CustomButton(
              text: 'Go to Dashboard',
              icon: Icons.dashboard,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                  (route) => false,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (isScanning && barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() => isScanning = false);
        controller.stop();
        _handleQRScan(code);
      }
    }
  }

  Future<void> _handleQRScan(String qrCode) async {
    setState(() => isLoading = true);

    try {
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
      
      // Look up organization by QR ID
      final organization = await organizationProvider.getOrganizationByQr(qrCode);

      if (organization != null) {
        setState(() {
          scannedOrganization = organization;
          isLoading = false;
        });
      } else {
        if (mounted) {
          UIHelper.showErrorDialog(context, 'Invalid QR code or organization not found');
          _resetScan();
        }
      }
    } catch (e) {
      print('❌ QR scan error: $e');
      if (mounted) {
        UIHelper.showErrorDialog(context, 'Failed to lookup organization');
        _resetScan();
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleSendJoinRequest() async {
    if (scannedOrganization == null) return;

    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final success = await organizationProvider.sendJoinRequest(
        userId: currentUser.uid,
        organizationId: scannedOrganization!.organizationId,
      );

      if (!mounted) return;

      if (success) {
        setState(() => requestSent = true);
        UIHelper.showSnackBar(
          context,
          'Join request sent successfully!',
        );
      } else {
        UIHelper.showSnackBar(
          context,
          organizationProvider.error ?? 'Failed to send join request',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Send join request error: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Error: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _resetScan() {
    setState(() {
      scannedOrganization = null;
      isScanning = true;
      requestSent = false;
    });
    controller.start();
  }
}

/// Custom overlay for scanner (same as in qr_code_widget.dart, but can be kept separate)
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
        // Semi-transparent background
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        // Cut-out area
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
        isTopLeft: false,
        isBottomRight: false,
        isTopRight: false,
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
        isTopLeft: false,
        isTopRight: false,
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