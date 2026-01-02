import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:quantum_space/core/network/my_odoo_connect.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/auth/presentation/provider/account_provider.dart';

import '../../../../util/util.dart';

class AuthRepository {
  final AccountNotifier _accountNotifier;
  AuthRepository(this._accountNotifier);

  Future<OdooAccountModule> login(
    String url,
    String username,
    String password,
  ) async {
    final OdooClient odooClient = MyOdooConnect(url).odooClient;
    final session = await odooClient.authenticate(
      Util().dbName(url),
      username,
      password,
    );
    odooClient.close();
    final OdooAccountModule module = OdooAccountModule(
      url: url,
      username: username,
      password: password,
      sessionId: session.id,
      personName: session.userName,
      uid: session.userId,
    );
    await _accountNotifier.newLogin(module);
    return module;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(accountsProvider.notifier)),
);
