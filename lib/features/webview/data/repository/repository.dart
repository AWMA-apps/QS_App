import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quantum_space/core/network/my_dio.dart';
import 'package:quantum_space/features/webview/domain/repository/repository_intf.dart';

class WebviewRepositoryImpl extends WebViewRepositoryIntrf {
  @override
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) return true;
      return await Permission.manageExternalStorage.request().isGranted;
    }
    return true;
  }

  @override
  Future<String?> saveFile(List<int> bytes, String fileName) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/Quantum Space');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      if (!await directory.exists()) await directory.create(recursive: true);

      final String filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print("Save File Error ❌$e");
      }
    }
    return null;
  }
}

class NotificationsRepositoryImpl extends NotificationsRepositoryIntrf {
  final MyDio myDio;

  NotificationsRepositoryImpl(this.myDio);

  @override
  void updateTokenInOdoo(String token, String sessionId) async {
    final response = await myDio.dio.post(
      "/api/fcm/update_token",
      data: {"fcm_token": token},
      options: Options(
        headers: {
          "Cookie": "session_id=$sessionId",
        },
      ),
    );
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("✅✅✅✅✅✅✅✅✅✅✅TOKEN UPDATED!✅✅✅✅✅✅✅✅✅✅✅ response= $response");
      }
    } else {
      if (kDebugMode) {
        print("⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔TOKEN NOT UPDATED⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔");
      }
    }
  }

  void deleteToken() async {
    await FirebaseMessaging.instance.deleteToken();
  }
}
