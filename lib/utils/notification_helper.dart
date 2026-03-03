// Notification Helper
class NotificationHelper {
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    DateTime? scheduledTime,
  }) async {
    // Implementation for scheduling local notifications
    print('Scheduling notification: $title');
  }

  static Future<void> cancelNotification(int id) async {
    print('Cancelling notification: $id');
  }

  static Future<void> cancelAllNotifications() async {
    print('Cancelling all notifications');
  }
}
