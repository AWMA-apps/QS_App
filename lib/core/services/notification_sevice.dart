import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static void show(String title, String body) {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('channel_id', 'Odoo Updates',
          importance: Importance.max, priority: Priority.high),
    );
    _notifications.show(DateTime.now().millisecond, title, body, details);
  }
}