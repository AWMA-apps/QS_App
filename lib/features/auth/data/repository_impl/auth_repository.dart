import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_space/core/odoo_api/odoo_connect.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/auth/presentation/provider/account_provider.dart';

class AuthRepository {
  final OdooConnect _odooConnect = OdooConnect();
  final AccountNotifier _accountNotifier;

  AuthRepository(this._accountNotifier);

  Future<OdooAccountModule> login(
    String url,
    String username,
    String password,
  ) async {
    final session = await _odooConnect.getSession(url, username, password);
    final OdooAccountModule module = OdooAccountModule(
      url: url,
      username: username,
      password: password,
      sessionId: session.id,
      personName: session.userName,
    );
    await _accountNotifier.newLogin(module);
    return module;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(accountsProvider.notifier)),
);
