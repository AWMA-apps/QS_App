import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/webview/data/repository/repository.dart';
import 'package:quantum_space/features/webview/presentation/provider/provider.dart';

import '../../../../core/constants/js_scripts.dart';
import '../../../../core/services/fcm_notifications.dart';
import '../../../../core/services/show_notification.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/provider/account_provider.dart';

class AppWebView extends ConsumerStatefulWidget {
  final OdooAccountModule account;

  AppWebView({super.key, required this.account}) {
    initializeNotifications();
    FCMNotificationService().initNotifications();
  }

  @override
  ConsumerState<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends ConsumerState<AppWebView> {
  DateTime? _lastPressedAt;
  late CookieManager cookieManager;
  late OdooAccountModule account;

  @override
  void initState() {
    super.initState();
    account = widget.account;
    cookieManager = CookieManager.instance();
  }

  Future<void> _handlePopScope(
    bool didPop,
    Object? result,
    BuildContext context,
    AppLocalizations tr,
  ) async {
    if (didPop) return;
    final now = DateTime.now();
    const backButtonInterval = Duration(seconds: 2);
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > backButtonInterval) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.press_back_again_to_exit),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    var url = navigationAction.request.url.toString();
    if (kDebugMode) {
      print("⛔shouldOverrideUrlLoading⛔ $url⛔");
    }
    if (url.contains("session/logout")) {
      await CookieManager.instance().deleteAllCookies();
      await controller.evaluateJavascript(
        source: "window.localStorage.clear();",
      );
      return NavigationActionPolicy.ALLOW;
    }
    return NavigationActionPolicy.ALLOW;
  }

  Widget _buildWebview(
    BuildContext context,
    WebviewLogic logic,
    WidgetRef ref,
    AppLocalizations tr,
  ) {
    return SafeArea(
      child: InAppWebView(
        initialSettings: InAppWebViewSettings(
          userAgent:
              "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
          javaScriptEnabled: true,
          useOnDownloadStart: true,
          allowFileAccessFromFileURLs: true,
          databaseEnabled: true,
          domStorageEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          allowFileAccess: true,
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) =>
            _shouldOverrideUrlLoading(controller, navigationAction),
        onWebViewCreated: (controller) =>
            _onWebViewCreated(controller, account, cookieManager),
        onDownloadStartRequest: (controller, downloadRequest) =>
            _onDownloadStartRequest(
              downloadRequest,
              logic,
              account,
              cookieManager,
              controller,
            ),
        onLoadStop: (controller, url) =>
            controller.evaluateJavascript(source: JsScripts.jsBlobHandler),
        onLoadStart: (controller, url) =>
            _checkSession(url.toString(), account, ref, context),
        onProgressChanged: (_, p) =>
            ref.read(loadingProgressProvider.notifier).state = p,
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, int progress) {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 50),
        color: Theme.of(context).colorScheme.primary,
        child: LinearProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
          value: progress / 100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(loadingProgressProvider);
    final logic = ref.read(webviewLogicProvider);
    final tr = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) =>
          _handlePopScope(didPop, result, context, tr),
      child: Scaffold(
        body: Stack(
          children: [
            _buildWebview(context, logic, ref, tr!),
            if (progress < 100) _buildProgressIndicator(context, progress),
          ],
        ),
      ),
    );
  }
}

void _checkSession(
  String? url,
  OdooAccountModule account,
  WidgetRef ref,
  BuildContext context,
) {
  if (url == null) return;
  if (url.contains("/login?") || url.contains("session/logout")) {
    final accProvider = ref.read(accountsProvider.notifier);
    accProvider.deleteLastActiveAccount(account);
    context.pushReplacement("/login");
    if (kDebugMode) {
      print("⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔⛔");
    }
  }
}

void _onDownloadStartRequest(
  DownloadStartRequest downloadRequest,
  WebviewLogic logic,
  OdooAccountModule account,
  CookieManager cookieManager,
  InAppWebViewController webViewController,
) {
  final String urlString = downloadRequest.url.toString();
  //print("⛔onDownloadStartRequest⛔ $urlString");
  if (urlString.startsWith("blob:")) {
    webViewController.evaluateJavascript(
      source: "window.atob_blob('$urlString');",
    );
  } else {
    logic.downloadFie(
      urlString,
      downloadRequest.suggestedFilename!,
      account.sessionId,
      cookieManager,
    );
  }
}

void _onWebViewCreated(
  InAppWebViewController controller,
  OdooAccountModule account,
  CookieManager cookieManager,
) async {
  await cookieManager.deleteAllCookies();
  await cookieManager.setCookie(
    url: WebUri(account.url),
    name: "session_id",
    value: account.sessionId,
    domain: WebUri(account.url).host,
    path: "/",
    isSecure: true,
  );

  await controller.loadUrl(
    urlRequest: URLRequest(url: WebUri("${account.url}/web")),
  );
  controller.addJavaScriptHandler(
    handlerName: 'onBlobConverted',
    callback: (args) async {
      final Map<String, dynamic> result = args[0];
      String rawData = result['data'];
      String fileName = result['fileName'];
      String base64Data = rawData.contains(',')
          ? rawData.split(',')[1]
          : rawData;
      try {
        final decodedBytes = base64Decode(base64Data.trim());
        final path = await WebviewRepositoryImpl().saveFile(
          decodedBytes,
          fileName,
        );
        if (path != null) showDownloadFinishedNotification(fileName, path);
        if (kDebugMode) {
          print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅");
        }
      } catch (e) {
        debugPrint("Error decoding base64: $e");
      }
    },
  );
}
