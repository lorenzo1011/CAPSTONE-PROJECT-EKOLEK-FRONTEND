import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ekolek_app/app/app.dart';
import 'package:ekolek_app/app/app_routes.dart';
import 'package:ekolek_app/app/router.dart';
import 'package:ekolek_app/core/api/api_client.dart';
import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/core/config/app_config.dart';
import 'package:ekolek_app/core/services/connectivity_service.dart';
import 'package:ekolek_app/features/auth/models/auth_user.dart';
import 'package:ekolek_app/features/auth/models/login_request.dart';
import 'package:ekolek_app/features/auth/screens/account_status_screen.dart';
import 'package:ekolek_app/features/auth/screens/login_screen.dart';
import 'package:ekolek_app/features/auth/services/auth_service.dart';
import 'package:ekolek_app/shared/providers/auth_providers.dart';
import 'package:ekolek_app/shared/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  test(
    'login uses the verified endpoint, fields, and token envelope',
    () async {
      final adapter = _ContractAdapter();
      final client = ApiClient(config: AppConfig(enableNetworkLogs: false));
      client.dio.httpClientAdapter = adapter;
      final service = AuthService(apiClient: client);

      final result = await service.login(
        const LoginRequest(email: 'resident@example.test', password: 'secret'),
      );

      expect(adapter.request?.path, ApiEndpoints.login);
      expect(adapter.request?.path, 'auth/login/');
      expect(adapter.request?.data, {
        'email': 'resident@example.test',
        'password': 'secret',
      });
      expect(result.tokens.accessToken, 'access-value');
      expect(result.tokens.refreshToken, 'refresh-value');
      expect(result.toString(), isNot(contains('access-value')));
      expect(
        const LoginRequest(email: 'a', password: 'secret').toString(),
        isNot(contains('secret')),
      );
      client.dio.close(force: true);
    },
  );

  test(
    'current-user response parses verified role and resident status',
    () async {
      final adapter = _ContractAdapter(currentUser: true);
      final client = ApiClient(config: AppConfig(enableNetworkLogs: false));
      client.dio.httpClientAdapter = adapter;
      final user = await AuthService(apiClient: client).getCurrentUser();
      expect(adapter.request?.path, ApiEndpoints.currentUser);
      expect(user.role, UserRole.resident);
      expect(user.approvalStatus, ResidentApprovalStatus.approved);
      expect(user.fullName, 'Verified Resident');
      client.dio.close(force: true);
    },
  );

  for (final entry in {
    ResidentApprovalStatus.pending: 'Account review in progress',
    ResidentApprovalStatus.rejected: 'Registration needs attention',
    ResidentApprovalStatus.suspended: 'Account access suspended',
    ResidentApprovalStatus.unknown: 'Account verification required',
  }.entries) {
    testWidgets('${entry.key.name} resident is restricted to Account Status', (
      tester,
    ) async {
      final auth = AuthTestHarness(user: _resident(entry.key));
      await auth.controller.initialize();
      addTearDown(auth.dispose);
      final router = createAppRouter(authController: auth.controller);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => auth.controller),
          ],
          child: EkolekApp(router: router),
        ),
      );
      router.goNamed(AppRoutes.games);
      await tester.pumpAndSettle();
      expect(find.byType(AccountStatusScreen), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('Play, learn, and earn responsibly'), findsNothing);
    });
  }

  testWidgets('approved resident is allowed into Home', (tester) async {
    final auth = AuthTestHarness();
    await auth.controller.initialize();
    addTearDown(auth.dispose);
    final router = createAppRouter(authController: auth.controller);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => auth.controller),
        ],
        child: EkolekApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Track your points, environmental impact, and community progress in one place.',
      ),
      findsOneWidget,
    );
  });

  test('non-resident restored session is denied and cleared', () async {
    final auth = AuthTestHarness(
      user: const AuthUser(
        id: 8,
        email: 'admin@example.test',
        role: UserRole.operationsAdmin,
        approvalStatus: ResidentApprovalStatus.unknown,
      ),
    );
    addTearDown(auth.dispose);
    await auth.controller.initialize();
    expect(auth.storage.tokens, isNull);
    expect(
      auth.controller.state.message,
      'This account is not authorized to use the E-KOLEK Resident App.',
    );
  });

  testWidgets('no session reaches Login and protected routes stay guarded', (
    tester,
  ) async {
    final auth = AuthTestHarness(hasSession: false);
    addTearDown(auth.dispose);
    final router = createAppRouter(authController: auth.controller);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => auth.controller),
        ],
        child: EkolekApp(router: router),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    router.goNamed(AppRoutes.games);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('login validates empty fields and toggles password visibility', (
    tester,
  ) async {
    final auth = AuthTestHarness(hasSession: false);
    await auth.controller.initialize();
    addTearDown(auth.dispose);
    final router = createAppRouter(authController: auth.controller);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => auth.controller),
          connectivityStatusProvider.overrideWithValue(
            const AsyncData(ConnectivityStatus.online),
          ),
        ],
        child: EkolekApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    final passwordInput = find.byType(EditableText).last;
    expect(tester.widget<EditableText>(passwordInput).obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<EditableText>(passwordInput).obscureText, isFalse);
  });

  testWidgets('logout clears tokens and returns to Login', (tester) async {
    final auth = AuthTestHarness();
    await auth.controller.initialize();
    addTearDown(auth.dispose);
    final router = createAppRouter(authController: auth.controller);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => auth.controller),
        ],
        child: EkolekApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    await auth.controller.logout();
    await tester.pumpAndSettle();
    expect(auth.storage.tokens, isNull);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

AuthUser _resident(ResidentApprovalStatus status) => AuthUser(
  id: 1,
  email: 'resident@example.test',
  role: UserRole.resident,
  approvalStatus: status,
  residentProfileId: 1,
);

class _ContractAdapter implements HttpClientAdapter {
  _ContractAdapter({this.currentUser = false});
  final bool currentUser;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final body = currentUser
        ? {
            'success': true,
            'data': {
              'user': {
                'id': 1,
                'email': 'resident@example.test',
                'role': 'RESIDENT',
              },
              'resident': {
                'id': 2,
                'full_name': 'Verified Resident',
                'approval_status': 'APPROVED',
                'rejection_reason': '',
              },
            },
          }
        : {
            'success': true,
            'data': {
              'user': {
                'id': 1,
                'email': 'resident@example.test',
                'role': 'RESIDENT',
              },
              'tokens': {'access': 'access-value', 'refresh': 'refresh-value'},
            },
          };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
