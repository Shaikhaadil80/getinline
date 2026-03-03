// =============================================================================
// GETINLINE FLUTTER - services/notification_service.dart
// Firebase Cloud Messaging Service for Push Notifications
// =============================================================================

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'database_service.dart';
import 'api_service.dart';
import '../utils/constants.dart';


  final FlutterLocalNotificationsPlugin localNotifications = 
      FlutterLocalNotificationsPlugin();
      // Background message handler for FCM
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  
  
const androidDetails = AndroidNotificationDetails(
    'getinline_channel',
    'GetInLine Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  await localNotifications.show(
    id: message.hashCode,
    title: message.notification?.title ?? 'New Notification',
    body: message.notification?.body ?? '',
    notificationDetails: const NotificationDetails(android: androidDetails),
  );
    // // Show local notification for background messages
    // _showLocalNotification(message);
}
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();

  // Notification tap callback
  Function(RemoteMessage)? onNotificationTap;

  // =============================================================================
  // INITIALIZATION
  // =============================================================================

  Future<void> initialize() async {
    print('🔔 Initializing Notification Service...');

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await _getFCMToken();

    // Listen to token refresh
    _fcm.onTokenRefresh.listen(_onTokenRefresh);

    // Setup FCM background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state via notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    print('✅ Notification Service initialized');
  }

  // =============================================================================
  // PERMISSION
  // =============================================================================

  Future<void> _requestPermission() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print(
        '🔔 Notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Provisional notification permission granted');
      } else {
        print('❌ Notification permission denied');
      }
    } catch (e) {
      print('❌ Error requesting permission: $e');
    }
  }

  // =============================================================================
  // LOCAL NOTIFICATIONS
  // =============================================================================

  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      print('✅ Local notifications initialized');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  // =============================================================================
  // FCM TOKEN
  // =============================================================================

  Future<String?> _getFCMToken() async {
    try {
      String? token;

      if (kIsWeb) {
        // Web: need VAPID key
        token = await _fcm.getToken(
          vapidKey:
              'BN-2GS-a6CucIOKhsFu2PJP3-xya4Chj473cm2B4HZGigaFA7w_4nBeECPAiM8vkZzt5S3Qsf6dz5icMwHixnIk',
        );
      } else {
        // Mobile / desktop
        if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          // iOS and macOS require APNs token first
          final apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) {
            token = await _fcm.getToken();
          }
        } else {
          // Android, Windows, etc.
          token = await _fcm.getToken();
        }
      }

      if (token != null) {
        print('🔔 FCM Token: $token');
        await _dbService.saveFcmToken(token);
        await _updateFCMTokenOnServer(token);
      }

      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }
  // Future<String?> _getFCMToken() async {
  //   try {
  //     String? token;

  //     if (Platform.isIOS) {
  //       // For iOS, get APNS token first
  //       final apnsToken = await _fcm.getAPNSToken();
  //       if (apnsToken != null) {
  //         token = await _fcm.getToken();
  //       }
  //     } else {
  //       token = await _fcm.getToken(vapidKey: kIsWeb ? 'BN-2GS-a6CucIOKhsFu2PJP3-xya4Chj473cm2B4HZGigaFA7w_4nBeECPAiM8vkZzt5S3Qsf6dz5icMwHixnIk' : null );
  //     }

  //     if (token != null) {
  //       print('🔔 FCM Token: $token');
  //       // await _dbService.saveFcmToken(token);
  //       // await _updateFCMTokenOnServer(token);
  //     }

  //     return token;
  //   } catch (e) {
  //     print('❌ Error getting FCM token: $e');
  //     return null;
  //   }
  // }

  void _onTokenRefresh(String token) async {
    print('🔔 FCM Token refreshed: $token');
    await _dbService.saveFcmToken(token);
    await _updateFCMTokenOnServer(token);
  }

  Future<void> _updateFCMTokenOnServer(String token) async {
    try {
      final uid = await _dbService.getUserUid();
      if (uid == null) return;

      await _apiService.patch(
        ApiConstants.updateFcmToken,
        body: {'fcmToken': token},
      );
      print('✅ FCM token updated on server');
    } catch (e) {
      print('❌ Error updating FCM token on server: $e');
    }
  }

  // =============================================================================
  // MESSAGE HANDLERS
  // =============================================================================

  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Foreground message received:');
    print('  Title: ${message.notification?.title}');
    print('  Body: ${message.notification?.body}');
    print('  Data: ${message.data}');

    // Show local notification for foreground messages
    _showLocalNotification(message);
  }

  // Background message handler for FCM
  // Future<void> _firebaseMessagingBackgroundHandler(
  //   RemoteMessage message,
  // ) async {
  //   print('Background message received: ${message.messageId}');
  //   print('Title: ${message.notification?.title}');
  //   print('Body: ${message.notification?.body}');
  //   _showLocalNotification(message);
  // }
  

  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped:');
    print('  Data: ${message.data}');

    // Call the callback if set
    if (onNotificationTap != null) {
      onNotificationTap!(message);
    }

    // Handle navigation based on notification data
    _handleNotificationNavigation(message);
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;

    // Navigate based on notification type
    if (data.containsKey('type')) {
      final type = data['type'];

      switch (type) {
        case 'appointment':
          // Navigate to appointment detail
          print('Navigate to appointment: ${data['appointmentId']}');
          break;

        case 'join_request':
          // Navigate to join requests
          print('Navigate to join requests');
          break;

        case 'professional_in':
          // Navigate to professional detail
          print('Navigate to professional: ${data['professionalId']}');
          break;

        default:
          print('Unknown notification type: $type');
      }
    }
  }

  // =============================================================================
  // SHOW LOCAL NOTIFICATION
  // =============================================================================

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'getinline_channel',
        'GetInLine Notifications',
        channelDescription: 'Notifications for GetInLine app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        notificationDetails: details,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  // Get current FCM token
  Future<String?> getToken() async {
    return await _getFCMToken();
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  // Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
      await _dbService.remove(StorageKeys.fcmToken);
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}
