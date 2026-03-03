// =============================================================================
// GETINLINE FLUTTER - utils/build_config.dart
// Build Configuration and Version Management
// =============================================================================

import 'package:flutter/foundation.dart';
import 'environment_config.dart';

class BuildConfig {
  // App Information
  static const String appName = 'GetInLine';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  static const String packageName = 'com.example.getinline';
  
  // Build Type
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;
  
  // Environment
  static Environment get environment => EnvironmentConfig.current;
  
  // Platform
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isWeb => kIsWeb;
  
  // Feature Flags
  static bool get enableLogging => isDebug || environment == Environment.development;
  static bool get enablePerformanceMonitoring => isRelease;
  static bool get enableCrashlytics => isRelease;
  
  // Build Metadata
  static String get buildMetadata {
    final env = environment.toString().split('.').last;
    final platform = isAndroid ? 'Android' : isIOS ? 'iOS' : 'Web';
    final buildType = isDebug ? 'Debug' : isRelease ? 'Release' : 'Profile';
    return '$appName v$appVersion ($buildNumber) - $env - $platform - $buildType';
  }
  
  // Print build info (useful for debugging)
  static void printBuildInfo() {
    if (enableLogging) {
      print('=====================================');
      print('BUILD INFORMATION');
      print('=====================================');
      print('App: $appName');
      print('Version: $appVersion');
      print('Build: $buildNumber');
      print('Environment: ${environment.toString().split('.').last}');
      print('Platform: ${isAndroid ? 'Android' : isIOS ? 'iOS' : 'Web'}');
      print('Build Type: ${isDebug ? 'Debug' : isRelease ? 'Release' : 'Profile'}');
      print('API URL: ${EnvironmentConfig.apiBaseUrl}');
      print('=====================================');
    }
  }
}
