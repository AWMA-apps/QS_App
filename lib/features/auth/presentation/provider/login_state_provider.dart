import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/auth/data/repository_impl/auth_repository.dart';

enum LoginStatuses { initial, loading, success, error }

class LoginState {
  final LoginStatuses loginStatus;
  final String? error;

  LoginState({required this.loginStatus, this.error});
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _repository;

  LoginNotifier(this._repository)
    : super(LoginState(loginStatus: LoginStatuses.initial));
  Future<void> login(
    String url,
    String username,
    String password,
    Function(OdooAccountModule) onSuccess,
  ) async {
    state = LoginState(loginStatus: LoginStatuses.loading);
    try {
      final account = await _repository.login(url, username, password);
      onSuccess(account);
      state = LoginState(loginStatus: LoginStatuses.success);
    } catch (e) {
      state = LoginState(loginStatus: LoginStatuses.error, error: e.toString());
    }
  }
}

final loginStateProvider = StateNotifierProvider<LoginNotifier,LoginState>((ref) =>
  LoginNotifier(ref.watch(authRepositoryProvider)),);
