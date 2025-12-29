import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:quantum_space/core/odoo_api/odoo_connect.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/auth/presentation/provider/account_provider.dart';
import 'package:quantum_space/features/auth/presentation/provider/login_state_provider.dart';
import 'package:quantum_space/features/auth/presentation/widgets/my_text_form_field.dart';
import 'package:quantum_space/l10n/app_localizations.dart';

import '../../../../util/util.dart';
import '../../../webview/presentation/pages/webview_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  void _showAllAccounts() {
    showModalBottomSheet(
      enableDrag: true,
      showDragHandle: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final accounts = ref.watch(accountsProvider);
            final loggingState = ref.watch(loginStateProvider);
            bool _isLogging = loggingState.loginStatus == LoginStatuses.loading;

            if (accounts.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.no_accounts_left,
                  style: TextStyle(fontSize: 17),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (_isLogging) LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return Card(
                          key: ValueKey(account.url),
                          elevation: 2,
                          child: ListTile(
                            onTap: () {
                              ref
                                  .read(loginStateProvider.notifier)
                                  .login(
                                    account.url,
                                    account.username,
                                    account.password,
                                    (account) => context.pushReplacement(
                                      "/inappwebview",
                                      extra: account,
                                    ),
                                  );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Util().getAvatarColor(
                                account.personName,
                              ),
                              child: Text(
                                account.personName[0],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              account.personName,
                              style: TextStyle(fontSize: 22),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              account.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                ref
                                    .read(accountsProvider.notifier)
                                    .deleteAccount(account);
                              },
                              icon: Icon(Icons.delete_outline_rounded),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final tr = AppLocalizations.of(context)!;
    final loginState = ref.watch(loginStateProvider);

    ref.listen(loginStateProvider, (previous, next) {
      if (next.loginStatus == LoginStatuses.error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 50),
              child: Image.asset("assets/images/odoo_logo.png", width: 120),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  MyTextFormField(
                    autoFillHint: [AutofillHints.url],
                    keyboardType: TextInputType.url,
                    controller: _urlController,
                    labelText: tr.server_address,
                    prefixIcon: Icons.link,
                    validator_error_text: tr.server_is_required,
                  ),
                  const SizedBox(height: 12),
                  MyTextFormField(
                    autoFillHint: [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    labelText: tr.username,
                    prefixIcon: Icons.person_3_outlined,
                    validator_error_text: tr.username_is_required,
                  ),
                  const SizedBox(height: 12),
                  MyTextFormField(
                    autoFillHint: [AutofillHints.password],
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passController,
                    labelText: tr.password,
                    prefixIcon: Icons.lock_outline,
                    validator_error_text: tr.password_is_required,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: (loginState.loginStatus == LoginStatuses.loading)
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(loginStateProvider.notifier)
                                  .login(
                                    _urlController.text,
                                    _emailController.text,
                                    _passController.text,
                                    (account) => context.pushReplacement(
                                      "/inappwebview",
                                      extra: account,
                                    ),
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      minimumSize: Size(double.infinity, 35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(tr.login, style: TextStyle(color: Colors.white)),
                        if (loginState.loginStatus == LoginStatuses.loading)
                          LinearProgressIndicator(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _showAllAccounts,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr.or_select_another_account,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 18
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_up_sharp,color: Colors.white,size: 30,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
