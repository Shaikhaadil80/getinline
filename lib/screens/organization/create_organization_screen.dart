// =============================================================================
// GETINLINE FLUTTER - screens/organization/full_create_organization_screen.dart
// Complete Organization Creation with QR Generation and Image Upload
// =============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'admin_dashboard.dart';
import 'join_organization_screen.dart';

class CreateOrganizationScreen extends StatefulWidget {
  const CreateOrganizationScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrganizationScreen> createState() => _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends State<CreateOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organization'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Setup Your Organization',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your organization to start managing appointments',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Organization Logo/Image
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: _isUploadingImage
                            ? const Center(child: CircularProgressIndicator())
                            : _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: FutureBuilder(
                                      future: _selectedImage?.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          return Image.memory(
                                            snapshot.data as Uint8List,
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                      // child: Image.file(
                                      //   _selectedImage,
                                      //   fit: BoxFit.cover,
                                      // ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add Logo',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Optional',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Organization Name
              CustomTextField(
                controller: _nameController,
                label: 'Organization Name',
                hint: 'Enter organization name',
                prefixIcon: Icons.business,
                validator: Validators.validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Mobile Number
              CustomTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: 'Enter 10-digit mobile number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.validateMobile,
                maxLength: 10,
              ),
              const SizedBox(height: 16),

              // Address
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter organization address',
                prefixIcon: Icons.location_on,
                validator: Validators.validateAddress,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Info Card
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
                        'You will be set as the admin of this organization. A unique QR code will be generated for easy joining.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              CustomButton(
                text: 'Create Organization',
                icon: Icons.add_business,
                onPressed: _handleCreateOrganization,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // Join Organization Option
              Center(
                child: Column(
                  children: [
                    Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JoinOrganizationScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Join Existing Organization'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = XFile(image.path);
        });

        // // Upload to Cloudinary (mock implementation)
        // // In real app, you would upload to Cloudinary here
        // // and get the URL back
        // setState(() => _isUploadingImage = true);
        
        // // Simulate upload
        // await Future.delayed(const Duration(seconds: 2));
        
        // // Mock URL - replace with actual Cloudinary upload
        // _imageUrl = 'https://example.com/uploaded-image.jpg';
        
        // setState(() => _isUploadingImage = false);
        
        // if (mounted) {
        //   UIHelper.showSnackBar(context, 'Image uploaded successfully');
        // }
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Failed to pick image',
          isError: true,
        );
      }
    }
  }


Future<void> _handleCreateOrganization() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    // Determine pic parameter: if an image was selected, use the File object
    dynamic picParam;
    if (_selectedImage != null) {
      picParam = _selectedImage;  // this should be a File
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      picParam = _imageUrl;    // direct URL string
    } // else picParam stays null

    // Create organization (createdBy is not sent to backend; kept for local use if needed)
    final success = await organizationProvider.createOrganization(
      organizationName: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      address: _addressController.text.trim(),
      latlong: null, // add if you have location
      pic: picParam,
      createdBy: currentUser.uid, // kept for provider internal use if needed
    );

    if (!mounted) return;

    if (success) {
      // Update user's organization ID and role
      final orgId = organizationProvider.currentOrganization?.organizationId;
      if (orgId != null) {
        authProvider.updateOrganizationId(orgId);
        authProvider.updateUserRole(AppConstants.roleAdmin);
      }

      UIHelper.showSuccessDialog(
        context,
        'Organization created successfully!',
        onClose: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
            (route) => false,
          );
        },
      );
    } else {
      UIHelper.showSnackBar(
        context,
        organizationProvider.error ?? 'Failed to create organization',
        isError: true,
      );
    }
  } catch (e) {
    print('❌ Create organization error: $e');
    if (mounted) {
      UIHelper.showSnackBar(
        context,
        'Error: ${e.toString()}',
        isError: true,
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  // Future<void> _handleCreateOrganization() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //     final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

  //     final currentUser = authProvider.currentUser;
  //     if (currentUser == null) {
  //       throw Exception('User not logged in');
  //     }

  //     // Create organization
  //     final success = await organizationProvider.createOrganization(
  //       organizationName: _nameController.text.trim(),
  //       mobile: _mobileController.text.trim(),
  //       address: _addressController.text.trim(),
  //       picUrl: _imageUrl,
  //       createdBy: currentUser.uid,
  //     );

  //     if (!mounted) return;

  //     if (success) {
  //       // Update user's organization ID
  //       final orgId = organizationProvider.currentOrganization?.organizationId;
  //       if (orgId != null) {
  //         authProvider.updateOrganizationId(orgId);
  //         authProvider.updateUserRole(AppConstants.roleAdmin);
  //       }

  //       // Show success and navigate
  //       UIHelper.showSuccessDialog(
  //         context,
  //         'Organization created successfully!',
  //         onClose: () {
  //           Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (_) => const AdminDashboard()),
  //             (route) => false,
  //           );
  //         },
  //       );
  //     } else {
  //       UIHelper.showSnackBar(
  //         context,
  //         organizationProvider.error ?? 'Failed to create organization',
  //         isError: true,
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Create organization error: $e');
  //     if (mounted) {
  //       UIHelper.showSnackBar(
  //         context,
  //         'Error: ${e.toString()}',
  //         isError: true,
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
