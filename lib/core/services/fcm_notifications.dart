import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:quantum_space/core/network/my_dio.dart';
import 'package:quantum_space/core/services/show_notification.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/webview/data/repository/repository.dart';

class FCMNotificationService {
  final _fcm = FirebaseMessaging.instance;

  Future<String?> initNotifications(OdooAccountModule account) async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Get the FCM Token (For sending test messages)
    String? token = await _fcm.getToken();
    debugPrint("⛔⛔⛔FCM Token: $token");
    NotificationsRepositoryImpl(MyDio(account.url)).updateTokenInOdoo(token!,account.sessionId);
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
    return token;
  }
}
