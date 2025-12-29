import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:quantum_space/core/services/notification_sevice.dart';
import 'package:quantum_space/util/util.dart';

class OdooConnect {
  late OdooClient _client;
  int lastSeenNotificationId = 0;

  void initialize(String url) {
    _client = OdooClient(url);
  }

  Future<OdooSession> getSession(
    String url,
    String username,
    String password,
  ) async {
    _client = OdooClient(url);
    try {
      final session = await _client.authenticate(
        Util().dbName(url),
        username,
        password,
      );
      //final res = await _client.callRPC('/web/session/modules', 'call', {});
      //print('Installed modules: \n' + res.toString());
      _client.close();
      //checkForNotifications();
      return session;
    } on OdooException catch (e) {
      print("getSession01 ${e.message}");
      _client.close();
      rethrow;
    } catch (e) {
      print("getSession02: ${e.toString()}");
      _client.close();
      rethrow;
    }
  }

  void checkForNotifications() async {
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      print("OdooPoller ---////--- 🔄");
      try {
        final List<dynamic> messages = await _client.callRPC(
          '/web/dataset/call_kw',
          'call',
          {
            'model': 'mail.message',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': [
                ['message_type', '=', 'comment'],
                // جلب الرسائل الفعلية (التعليقات والدردشة)
              ],
              'fields': ['body', 'author_id', 'id'],
              'limit': 5,
              'order': 'id desc',
            },
          },
        );
        print("OdooPoller - messages 🔄 ${messages.length}");
        if (messages.isNotEmpty) {
          final Map<String,dynamic> msg = messages[0];
          print("Last Message - msg 🔄 ${msg.toString()}");

          int msgId = msg['id'];

          if (msgId > lastSeenNotificationId) {
            lastSeenNotificationId = msgId;
            _showLocalNotification(msg);
          }
        }
        _client.close();
      } catch (e) {
        print("Error in checkForNotifications: ❌$e");
      }
      // لا تغلق الكلاينت هنا (client.close) إذا كنت ستستخدمه مرة أخرى بعد 60 ثانية
    });
  }

  void _showLocalNotification(Map<String, dynamic> msg) {
    print("showLocalNotification: #$msg");
    final String body = msg['body'].replaceAll(RegExp(r'<[^>]*>'), '').trim();
    final String author = msg['author_id'][1];

    NotificationService.show(author, body);
    // const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    //   'odoo_channel_id',
    //   'Odoo Notifications',
    //   importance: Importance.max,
    //   priority: Priority.high,
    // );
    //
    // const NotificationDetails platformDetails = NotificationDetails(
    //     android: androidDetails);
    //
    // FlutterLocalNotificationsPlugin().show(
    //   DateTime
    //       .now()
    //       .millisecond,
    //   jsonMsg['author_id'][1],
    //   jsonMsg['body'].replaceAll(RegExp(r'<[^>]*>'), '').trim(),
    //   platformDetails,
    // );
  }
}
