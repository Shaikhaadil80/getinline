// =============================================================================
// GETINLINE FLUTTER - utils/environment_config.dart
// Environment Configuration for Different Build Environments
// =============================================================================

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _current = Environment.development;
  
  static Environment get current => _current;
  
  static void setEnvironment(Environment env) {
    _current = env;
  }
  
  // API URLs
  static String get apiBaseUrl {
    switch (_current) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.getinline.com/api';
      case Environment.production:
        return 'https://api.getinline.com/api';
    }
  }
  
  // WebSocket URLs
  static String get websocketUrl {
    switch (_current) {
      case Environment.development:
        return 'ws://localhost:3000';
      case Environment.staging:
        return 'wss://staging-api.getinline.com';
      case Environment.production:
        return 'wss://api.getinline.com';
    }
  }
  
  // Feature Flags
  static bool get enableAnalytics => _current == Environment.production;
  static bool get enableCrashReporting => _current != Environment.development;
  static bool get enableDebugLogging => _current == Environment.development;
  
  // API Timeout
  static Duration get apiTimeout {
    switch (_current) {
      case Environment.development:
        return const Duration(seconds: 60);
      case Environment.staging:
        return const Duration(seconds: 45);
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }
  
  // App Settings
  static int get maxAppointmentsPerDay => 3;
  static int get queueRefreshInterval => 30; // seconds
  static int get notificationCheckInterval => 60; // seconds
  
  // External Services
  static String get cloudinaryUrl => 'https://api.cloudinary.com/v1_1/getinline';
  static String get cloudinaryUploadPreset => 'getinline_uploads';
  
  // Pagination
  static int get defaultPageSize => 20;
  static int get maxPageSize => 100;
  
  // Map Configuration
  static String get googleMapsApiKey {
    switch (_current) {
      case Environment.development:
        return 'YOUR_DEV_GOOGLE_MAPS_KEY';
      case Environment.staging:
        return 'YOUR_STAGING_GOOGLE_MAPS_KEY';
      case Environment.production:
        return 'YOUR_PROD_GOOGLE_MAPS_KEY';
    }
  }
}
