import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
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
      if (kDebugMode) {
        print("getSession01 ${e.message}");
      }
      _client.close();
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("getSession02: ${e.toString()}");
      }
      _client.close();
      rethrow;
    }
  }

}
