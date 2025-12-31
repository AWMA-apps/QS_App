import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:quantum_space/core/services/show_notification.dart';

class FCMNotificationService {
  final _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
   await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Get the FCM Token (For sending test messages)
    String? token = await _fcm.getToken();
    debugPrint("⛔⛔⛔FCM Token: $token");
    // cFcT350PQ7WFmzMKhOoNDc:APA91bGfStNBS4o2m0hxI8r0bd17R40VTctEH-520HWuyxIKZ2XXZ6OqHAX6cN-AIlVOkknK5_1f22eVlHNJVHJM4di9IoRnKrTl7ZAkVQyn6LQRhVnDemQ

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String title = message.notification?.title ?? "";
      String text = message.notification?.body ?? "";
      debugPrint("Foreground Message: $title : $text");
      showFcmNotification(title, text);
    });

    // 4. Handle Interaction (When user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification Tapped!");
    });
  }
}