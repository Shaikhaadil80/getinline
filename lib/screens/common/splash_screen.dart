// =============================================================================
// GETINLINE FLUTTER - screens/common/splash_screen.dart
// Splash Screen with Auto-Navigation
// =============================================================================

import 'package:flutter/material.dart';
import 'package:getinline/screens/auth/create_update_profile_screen.dart';
import 'package:getinline/screens/common/onboarding_screen.dart';
import 'package:getinline/screens/customer/comprehensive_customer_dashboard.dart';
import 'package:getinline/screens/organization/create_organization_screen.dart';
import 'package:getinline/services/database_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../auth/user_login_screen.dart';
// import '../customer/customer_dashboard.dart';
import '../organization/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    final loginPageName = await _dbService.getLoginPageName();

    if (!mounted) return;

    Widget nextScreen;

    if (authProvider.isAuthenticated) {
      // User is logged in
      print("authProvider.currentUser ${authProvider.currentUser}");
      if (authProvider.currentUser == null) {
        nextScreen = CreateUpdateProfileScreen(
          uid: authProvider.firebaseCurrentUser!.uid,
        );
      } else if (loginPageName == AppConstants.organizationLoginPage) {
        if (authProvider.hasOrganization) {
          nextScreen = const AdminDashboard();
        } else {
          nextScreen = const CreateOrganizationScreen();
        }
      } else {
        nextScreen = const CustomerDashboard();
      }
    } else {
      // Check if first time user
      final isFirstTime = await _isFirstTimeUser();
      nextScreen = isFirstTime
          ? const OnboardingScreen()
          : const UserLoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<bool> _isFirstTimeUser() async {
    // Check SharedPreferences for first-time flag
    // For now, return false (skip onboarding)

    return await _dbService.getFirstTimeUser() ?? true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book appointments hassle-free',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
