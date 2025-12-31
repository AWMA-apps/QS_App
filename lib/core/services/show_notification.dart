import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) async {
      if (kDebugMode) {
        print("⛔onDidReceiveNotificationResponse: ⛔$details⛔");
      }
      if (details.payload != null) {
        await OpenFilex.open(details.payload!);
      }
    },
  );
}

Future<void> showDownloadFinishedNotification(
  String fileName,
  String filePath,
) async {
  if (Platform.isAndroid) {
    var status = await Permission.notification.request();
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'download_channel_id',
        'Download Channel',
        channelDescription: 'Your Download Notifications Channel',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    fileName.hashCode,
    'Download Completed',
    fileName,
    platformChannelSpecifics,
    payload: filePath,
  );
}

Future<void> showFcmNotification(String title, String text) async {
  await FirebaseMessaging.instance
      .requestPermission(provisional: true);
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'odoo_notifications_channel',
    'Messages Channel',
    channelDescription: 'Your General Message Notifications Channel',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    title.hashCode,
    title,
    text,
    platformChannelSpecifics,
  );

}