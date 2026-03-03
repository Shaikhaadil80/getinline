// =============================================================================
// GETINLINE FLUTTER - screens/auth/user_login_screen.dart
// Customer Login Screen with Firebase Authentication
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getinline/screens/auth/organization_login_screen.dart';
import 'package:getinline/screens/customer/comprehensive_customer_dashboard.dart';
import 'package:getinline/services/database_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'create_update_profile_screen.dart';
// import '../customer/customer_dashboard.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final DatabaseService _dbService = DatabaseService();
  @override
  void initState() {
    super.initState();
    _dbService.saveLoginPageName(AppConstants.userLoginPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome Text
                const Text(
                  'Welcome to GetInLine',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Book appointments hassle-free',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Sign In Buttons
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      // Google Sign-In Button
                      _buildGoogleSignInButton(),
                      const SizedBox(height: 16),

                      // Apple Sign-In Button (iOS only)
                      if (Theme.of(context).platform == TargetPlatform.iOS ||
                          kIsWeb)
                        _buildAppleSignInButton(),
                    ],
                  ),

                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 32),

                // Navigate to Organization Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrganizationLoginScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: 'Are you an Organization? '),
                        TextSpan(
                          text: 'Login here',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Privacy & Terms
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.login, color: Colors.red);
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleAppleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.apple, size: 24),
            SizedBox(width: 12),
            Text(
              'Continue with Apple',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // Sign in with Google
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        setState(() => _isLoading = false);
        return;
      }

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Failed to get user ID');
      }

      if (!mounted) return;

      // Handle login through AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userExists = await authProvider.handleLogin(uid);

      if (!mounted) return;

      if (userExists) {
        // // User exists, check for organization
        // if (authProvider.hasOrganization) {
        //   // Should not happen for customer login, redirect to customer dashboard
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (_) => const AdminDashboard()),
        //   );
        // } else {
        //   // Customer without organization, go to dashboard
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (_) => const CustomerDashboard()),
        //   );
        // }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerDashboard()),
        );
      } else {
        // New user, needs to create profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CreateUpdateProfileScreen(uid: uid, isCustomer: true),
          ),
        );
      }
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Sign-in failed: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // Sign in with Apple
      final userCredential = await _authService.signInWithApple();

      if (userCredential == null) {
        setState(() => _isLoading = false);
        return;
      }

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Failed to get user ID');
      }

      if (!mounted) return;

      // Handle login through AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userExists = await authProvider.handleLogin(uid);

      if (!mounted) return;

      if (userExists) {
        // User exists, go to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerDashboard()),
        );
      } else {
        // New user, needs to create profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CreateUpdateProfileScreen(uid: uid, isCustomer: true),
          ),
        );
      }
    } catch (e) {
      print('❌ Apple Sign-In Error: $e');
      if (mounted) {
        UIHelper.showSnackBar(
          context,
          'Sign-in failed: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
