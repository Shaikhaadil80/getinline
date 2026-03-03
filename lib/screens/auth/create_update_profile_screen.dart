// =============================================================================
// GETINLINE FLUTTER - screens/auth/create_update_profile_screen.dart
// Profile Creation/Update Screen with Complete Validation
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/screens/customer/comprehensive_customer_dashboard.dart';
import 'package:getinline/screens/organization/create_organization_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
// import '../customer/customer_dashboard.dart';

class CreateUpdateProfileScreen extends StatefulWidget {
  final String uid;
  final bool isCustomer;
  final bool isUpdate;

  const CreateUpdateProfileScreen({
    Key? key,
    required this.uid,
    this.isCustomer = true,
    this.isUpdate = false,
  }) : super(key: key);

  @override
  State<CreateUpdateProfileScreen> createState() => _CreateUpdateProfileScreenState();
}

class _CreateUpdateProfileScreenState extends State<CreateUpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
    }
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _mobileController.text = user.mobile;
      _addressController.text = user.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpdate ? 'Update Profile' : 'Create Profile'),
        automaticallyImplyLeading: widget.isUpdate,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (!widget.isUpdate) ...[
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please complete your profile to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person,
                  validator: Validators.validateName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Mobile Field
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

                // Address Field
                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter your address',
                  prefixIcon: Icons.home,
                  validator: Validators.validateAddress,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: widget.isUpdate ? 'Update Profile' : 'Create Profile',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                ),

                if (!widget.isUpdate) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'You can update this information later',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (widget.isUpdate) {
        // Update existing profile
        final success = await authProvider.updateProfile(
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          address: _addressController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
          UIHelper.showSnackBar(context, SuccessMessages.profileUpdated);
          Navigator.pop(context);
        } else {
          UIHelper.showSnackBar(
            context,
            authProvider.error ?? 'Failed to update profile',
            isError: true,
          );
        }
      } else {
        // Create new profile
        final success = await authProvider.createProfile(
          uid: widget.uid,
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          address: _addressController.text.trim(),
          role: widget.isCustomer 
              ? AppConstants.roleCustomer 
              : AppConstants.roleAdmin,
        );

        if (!mounted) return;

        if (success) {
          // Navigate based on user type
          if (widget.isCustomer) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CustomerDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CreateOrganizationScreen()),
            );
          }
        } else {
          UIHelper.showSnackBar(
            context,
            authProvider.error ?? 'Failed to create profile',
            isError: true,
          );
        }
      }
    } catch (e) {
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

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
