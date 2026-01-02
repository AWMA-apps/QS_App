import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:quantum_space/util/util.dart';

class MyOdooClient {
  late OdooClient _client;

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
      _client.close();
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

  void updateTokenInOdoo(String token,String url,int uid)  {
    _client = OdooClient(url);
    _client.callKw({
      'model': 'res.users',
      'method': 'write',
      'args': [uid, {'fcm_token': token}],
      'kwargs': {},
    });
  }
}
