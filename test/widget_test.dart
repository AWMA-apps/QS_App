import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quantum_space/features/auth/data/module/odoo_account_module.dart';
import 'package:quantum_space/features/auth/presentation/pages/splash_screen.dart';
import 'package:quantum_space/features/auth/presentation/provider/account_provider.dart';

// 1. Create a Mock for your Notifier
class MockAccountsNotifier extends StateNotifier<List<OdooAccountModule>> with Mock
    implements AccountNotifier {
  MockAccountsNotifier(super.state);}

void main() {
  late MockAccountsNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockAccountsNotifier([]);
  });

  // Helper function to create the test environment
  Widget createTestWidget(GoRouter router) {
    return ProviderScope(
      overrides: [
        accountsProvider.overrideWith((ref) => mockNotifier),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('Splash Screen forwards to WebView when account exists', (tester) async {
    // Arrange: Mock returns an account
    when(() => mockNotifier.getLastActiveAccount())
        .thenAnswer((_) async => OdooAccountModule(
      url: "https://example.com",
      username: "user",
      password: "password",
      sessionId: "session",
      personName: "name"
    )); // Return any non-null object

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder:(context, state)  => const SplashScreen()),
        // We use a simple Text widget instead of the real AppWebView!
        GoRoute(path: '/inappwebview', builder:(context, state)  => const Text('DESTINATION_WEBVIEW')),
        GoRoute(path: '/login', builder:(context, state)  => const Text('DESTINATION_LOGIN')),
      ],
    );

    // Act
    await tester.pumpWidget(createTestWidget(router));

    // Verify Splash is visible initially
    expect(find.byType(Image), findsOneWidget);

    // Wait for the async logic and navigation to finish
    await tester.pumpAndSettle();

    // Assert: Check if we reached the WebView placeholder
    expect(find.text('DESTINATION_WEBVIEW'), findsOneWidget);
    expect(find.text('DESTINATION_LOGIN'), findsNothing);
  });

  testWidgets('Splash Screen forwards to Login when NO account exists', (tester) async {
    // Arrange: Mock returns null
    when(() => mockNotifier.getLastActiveAccount())
        .thenAnswer((_) async => null);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state)  => const SplashScreen()),
        GoRoute(path: '/inappwebview', builder: (context, state)  => const Text('DESTINATION_WEBVIEW')),
        GoRoute(path: '/login', builder: (context, state)  => const Text('DESTINATION_LOGIN')),
      ],
    );

    // Act
    await tester.pumpWidget(createTestWidget(router));

    await tester.pumpAndSettle();

    // Assert: Check if we reached the Login placeholder
    expect(find.text('DESTINATION_LOGIN'), findsOneWidget);
    expect(find.text('DESTINATION_WEBVIEW'), findsNothing);
  });
}