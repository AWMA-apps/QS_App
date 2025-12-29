import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:quantum_space/core/services/file_saved_notification.dart';
import 'package:quantum_space/features/webview/data/repository/repository.dart';

final loadingProgressProvider = StateProvider<int>((ref) => 0);
final webviewLogicProvider = Provider<WebviewLogic>((ref) => WebviewLogic(ref),);

class WebviewLogic {
  Ref ref;

  WebviewLogic(this.ref);

  Future<void> downloadFie(
    String url,
    String suggestedName,
    String sessionId,
    CookieManager cookieManager,
  ) async {
    try {
      List<Cookie> cookies = await cookieManager.getCookies(url: WebUri(url));
      String cookieString = cookies
          .map((c) => "${c.name}=${c.value}")
          .join("; ");
      final response = await http.get(
        Uri.parse(url),
        headers: {"Cookie": cookieString},
      );

      if (response.statusCode == 200) {
        if (!suggestedName.contains('.')) suggestedName += ".pdf";
        final webRepo = WebviewRepositoryImpl();
        final path = await webRepo.saveFile(response.bodyBytes, suggestedName);
        if(path !=null){
          downloadFinishedNotification(suggestedName, path);
        }
      }
    } catch (e) {
      print("Regular Download Failed e: $e");
    }
  }
}
