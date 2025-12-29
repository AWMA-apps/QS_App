import 'package:go_router/go_router.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/auth/presentation/pages/splash_screen.dart';
import 'package:quantum_space/features/webview/presentation/pages/inappwebview.dart';
import 'package:quantum_space/features/webview/presentation/pages/webview_page.dart';

import '../../features/auth/presentation/pages/login_page.dart';

final AppRouter = GoRouter(routes: [
  GoRoute(path: "/inappwebview",builder: (context, state) => AppWebView(account: state.extra as OdooAccountModule,),),
  GoRoute(path: "/webview",builder: (context, state) => AppWebView(account: state.extra as OdooAccountModule,),),
  GoRoute(path: "/login",builder: (context, state) => LoginPage(),),
  GoRoute(path: "/",builder: (context, state) => SplashScreen(),),
], initialLocation: "/");
//⛔✅⚠☢🔁💥