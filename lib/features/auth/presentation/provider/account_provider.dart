import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storageProvider = Provider<FlutterSecureStorage>(
  (ref) => FlutterSecureStorage(aOptions: const AndroidOptions()),
);

class AccountNotifier extends StateNotifier<List<OdooAccountModule>> {
  final String secureAccountsKey = "saved_accounts";
  final String lastActiveAccountKey = "last_active_account";
  final FlutterSecureStorage _secureStorage;

  AccountNotifier(this._secureStorage) : super([]) {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final data = await _secureStorage.read(key: secureAccountsKey);
    if (data != null) {
      final List decoded = json.decode(data);
      state = decoded.map((e) => OdooAccountModule.fromJSON(e)).toList();
    }
  }

  Future<void> newLogin(OdooAccountModule accountModule) async {
    // set last active account
    await setLastActiveAccount(accountModule);
    // is account saved?
    if (_isAccountSaved(accountModule)) {
      return;
    }
    // save the new account
    state = [...state, accountModule];
    await _secureStorage.write(
      key: secureAccountsKey,
      value: json.encode(state),
    );
   // print(state.length);
  }

  // awma-mo  & awma-awap
  Future<void> deleteAccount(OdooAccountModule account) async {
    // awma-mo
    state = state
        .where(
          (element) =>
              (account.url != element.url ||
              account.username != element.username),
        )
        .toList();
    await _secureStorage.write(
      key: secureAccountsKey,
      value: json.encode(state),
    );
  }

  bool _isAccountSaved(OdooAccountModule account) {
    return state.any(
      (element) =>
          (element.url == account.url && element.username == account.username),
    );
  }

  Future<OdooAccountModule?> getLastActiveAccount() async {
    final data = await _secureStorage.read(key: lastActiveAccountKey);
    if (data != null) {
      return OdooAccountModule.fromJSON(json.decode(data));
    } else {
      return null;
    }
  }

  Future<void> setLastActiveAccount(OdooAccountModule account) async {
    await _secureStorage.write(
      key: lastActiveAccountKey,
      value: json.encode(account),
    );
    //print("setLastActiveAccount: ${account.username}");
  }

  Future<void> deleteLastActiveAccount(OdooAccountModule account) async {
    // delete
    await _secureStorage.delete(key: lastActiveAccountKey);
  }

  Future<void> resetSessionId(OdooAccountModule account) async{
    state=state.map((e) {
      if(e.url==account.url && e.username==account.username){
        return e.copyWith(sessionId: "");
      }else{
        return e;
      }
    },).toList();
    await _secureStorage.write(
      key: secureAccountsKey,
      value: json.encode(state),
    );
  }

}

final accountsProvider =
    StateNotifierProvider<AccountNotifier, List<OdooAccountModule>>(
      (ref) => AccountNotifier(ref.watch(storageProvider)),
    );
