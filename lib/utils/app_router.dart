// =============================================================================
// GETINLINE FLUTTER - utils/app_router.dart
// Application Navigation and Routing Configuration
// =============================================================================

import 'package:flutter/material.dart';
// import 'package:getinline/main.dart';
import 'package:getinline/screens/common/splash_screen.dart';
import 'package:getinline/screens/customer/comprehensive_customer_dashboard.dart';
import '../screens/common/onboarding_screen.dart';
import '../screens/auth/user_login_screen.dart';
import '../screens/auth/organization_login_screen.dart';
// import '../screens/auth/create_update_profile_screen.dart';
// import '../screens/customer/customer_dashboard.dart';
import '../screens/organization/admin_dashboard.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String userLogin = '/user-login';
  static const String orgLogin = '/org-login';
  static const String createProfile = '/create-profile';
  static const String customerDashboard = '/customer-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        
      case userLogin:
        return MaterialPageRoute(builder: (_) => const UserLoginScreen());
        
      case orgLogin:
        return MaterialPageRoute(builder: (_) => const OrganizationLoginScreen());
        
      case customerDashboard:
        return MaterialPageRoute(builder: (_) => const CustomerDashboard());
        
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
