import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quantum_space/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../auth/data/module/odoo_account_module.dart';
import '../../../auth/presentation/provider/account_provider.dart';

class WebviewPage extends ConsumerStatefulWidget {
  final OdooAccountModule account;

  const WebviewPage({super.key,required this.account});

  @override
  ConsumerState<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends ConsumerState<WebviewPage> {
  late final WebViewController _controller;
  DateTime? _lastPressedAt;
  int _loadingProgress = 0;


  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onUrlChange: (UrlChange change) {
            String? newUrl = change.url;
            print('URL changed to: $newUrl');
            if (newUrl != null && newUrl.contains("/login?")) {
              // delete last active account
              final accProvider = ref.read(accountsProvider.notifier);
              accProvider.deleteLastActiveAccount(widget.account);
              context.pushReplacement("/");
            }
          },onPageFinished: (url) => print("onPageFinished: 💥$url💥"),
          onNavigationRequest:(request) {
            print("onNavigationRequest: 💥$request💥");
            return NavigationDecision.navigate;
          },onHttpError: (error) => print("onHttpError: 💥$error💥"),
        ),
      );
    _injectSessionAndLoad();
  }

  Future<void> requestNotificationPermissions() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _injectSessionAndLoad() async {
    final account = widget.account;
    print("account in injectSessionAndLoad: 💥$account💥");
    final uri = Uri.parse(account.url);
    final domain = uri.host;

    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();
    await cookieManager.setCookie(
      WebViewCookie(
        name: "session_id",
        value: account.session_id,
        domain: domain,
        path: "/",
      ),
    );
    _controller.loadRequest(Uri.parse("${account.url}/web"));
    await requestNotificationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final tr=AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        const backButtonInterval = Duration(seconds: 2);
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > backButtonInterval) {
          _lastPressedAt = now;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr!.press_back_again_to_exit),
              duration: Duration(seconds: 2),
              //action: SnackBarAction(label: tr.re_login, onPressed: () => context.pushReplacement("/login",)),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: _loadingProgress < 100
            ? Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 50),
          color: Theme
              .of(context)
              .colorScheme
              .primary,
          child: LinearProgressIndicator(
            color: Theme
                .of(context)
                .colorScheme
                .secondary,
            value: _loadingProgress / 100,
          ),
        )
            : SafeArea(child: WebViewWidget(controller: _controller)),
      ),
    );
  }
}
