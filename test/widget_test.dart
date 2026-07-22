import 'package:ekolek_app/app/app.dart';
import 'package:ekolek_app/app/app_routes.dart';
import 'package:ekolek_app/app/app_shell.dart';
import 'package:ekolek_app/app/router.dart';
import 'package:ekolek_app/features/auth/screens/splash_screen.dart';
import 'package:ekolek_app/features/games/providers/games_controller.dart';
import 'package:ekolek_app/shared/providers/auth_providers.dart';
import 'package:ekolek_app/shared/providers/games_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthTestHarness currentAuth;

  GoRouter newRouter() {
    currentAuth = AuthTestHarness();
    final authForTest = currentAuth;
    final router = createAppRouter(authController: currentAuth.controller);
    addTearDown(authForTest.dispose);
    addTearDown(router.dispose);
    return router;
  }

  Future<void> pumpApp(
    WidgetTester tester,
    GoRouter router, {
    Size size = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => currentAuth.controller),
          gamesControllerProvider.overrideWith(
            (ref) => _NoopGamesController(ref.read(gamesServiceProvider)),
          ),
        ],
        child: EkolekApp(router: router),
      ),
    );
    await tester.pump();
  }

  Future<void> openHome(
    WidgetTester tester,
    GoRouter router, {
    Size size = const Size(390, 844),
  }) async {
    await pumpApp(tester, router, size: size);
    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();
  }

  testWidgets('E-KOLEK app starts without throwing', (tester) async {
    await pumpApp(tester, newRouter());

    expect(tester.takeException(), isNull);
    await tester.pump(SplashScreen.minimumDisplayDuration);
  });

  testWidgets('splash screen displays the E-KOLEK title', (tester) async {
    await pumpApp(tester, newRouter());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('E-KOLEK'), findsOneWidget);
    expect(find.text('Recycling made rewarding'), findsOneWidget);
    await tester.pump(SplashScreen.minimumDisplayDuration);
  });

  testWidgets('splash flow reaches Home after the startup delay', (
    tester,
  ) async {
    await pumpApp(tester, newRouter());

    await tester.pump(SplashScreen.minimumDisplayDuration);
    await tester.pumpAndSettle();

    expect(find.text('Your E-KOLEK activity in one place'), findsOneWidget);
  });

  testWidgets('main navigation displays all five destinations', (tester) async {
    await openHome(tester, newRouter());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('selecting Games opens the Games screen', (tester) async {
    await openHome(tester, newRouter());

    await tester.tap(find.text('Games'));
    // The Games screen intentionally displays a pulsing skeleton while its
    // authenticated request is pending, so it never has a fully settled frame.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Play, learn, and earn responsibly'), findsOneWidget);
  });

  testWidgets('selecting Rewards opens the Rewards screen', (tester) async {
    await openHome(tester, newRouter());

    await tester.tap(find.text('Rewards'));
    await tester.pumpAndSettle();

    expect(find.text('Turn your points into useful rewards'), findsOneWidget);
  });

  testWidgets('compact width uses NavigationBar', (tester) async {
    await openHome(tester, newRouter());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('tablet width uses NavigationRail', (tester) async {
    await openHome(tester, newRouter(), size: const Size(1024, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('unknown route displays the friendly error screen', (
    tester,
  ) async {
    final router = newRouter();
    await pumpApp(tester, router);
    await tester.pump(SplashScreen.minimumDisplayDuration);
    await tester.pump();

    router.go('/not-a-resident-route');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Return to Home'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('large text scaling does not overflow the main shell', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await openHome(tester, newRouter(), size: const Size(430, 900));

    expect(find.byType(AppShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _NoopGamesController extends GamesController {
  _NoopGamesController(super.service);

  @override
  Future<void> load({bool refresh = false}) async {}
}
