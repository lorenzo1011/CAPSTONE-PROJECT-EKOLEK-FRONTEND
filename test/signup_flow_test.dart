import 'dart:convert';
import 'dart:ui';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ekolek_app/app/app.dart';
import 'package:ekolek_app/app/router.dart';
import 'package:ekolek_app/core/api/api_client.dart';
import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/core/auth/auth_session_manager.dart';
import 'package:ekolek_app/core/auth/auth_tokens.dart';
import 'package:ekolek_app/core/auth/session_expired_handler.dart';
import 'package:ekolek_app/core/config/app_config.dart';
import 'package:ekolek_app/core/services/connectivity_service.dart';
import 'package:ekolek_app/features/auth/models/auth_user.dart';
import 'package:ekolek_app/features/auth/models/barangay_option.dart';
import 'package:ekolek_app/features/auth/models/login_result.dart';
import 'package:ekolek_app/features/auth/models/registration_request.dart';
import 'package:ekolek_app/features/auth/providers/auth_controller.dart';
import 'package:ekolek_app/features/auth/providers/auth_state.dart';
import 'package:ekolek_app/features/auth/screens/signup_screen.dart';
import 'package:ekolek_app/features/auth/services/auth_service.dart';
import 'package:ekolek_app/shared/providers/auth_providers.dart';
import 'package:ekolek_app/shared/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  test(
    'signup matches the Django registration and barangay contracts',
    () async {
      final adapter = _SignupContractAdapter();
      final client = ApiClient(config: AppConfig(enableNetworkLogs: false));
      client.dio.httpClientAdapter = adapter;
      final service = AuthService(apiClient: client);

      final barangays = await service.getActiveBarangays();
      expect(adapter.requests.first.path, ApiEndpoints.activeBarangays);
      expect(adapter.requests.first.path, 'barangays/active/');
      expect(barangays.single.name, 'San Vicente');

      final result = await service.register(
        RegistrationRequest(
          email: ' Resident@Example.test ',
          password: 'Password123!',
          fullName: ' Juan Dela Cruz ',
          birthdate: DateTime(1998, 5, 4),
          barangayId: 7,
          completeAddress: ' Block 1, Lot 2 ',
          phoneNumber: '09171234567',
        ),
      );

      final request = adapter.requests.last;
      expect(request.path, ApiEndpoints.register);
      expect(request.path, 'auth/register/');
      expect(request.data, isA<FormData>());
      final fields = Map<String, String>.fromEntries(
        (request.data as FormData).fields,
      );
      expect(fields, {
        'email': 'resident@example.test',
        'password': 'Password123!',
        'full_name': 'Juan Dela Cruz',
        'birthdate': '1998-05-04',
        'barangay': '7',
        'complete_address': 'Block 1, Lot 2',
        'phone_number': '09171234567',
      });
      expect(result.tokens.accessToken, 'signup-access');
      expect(result.tokens.refreshToken, 'signup-refresh');
      client.dio.close(force: true);
    },
  );

  test(
    'successful signup stores tokens and authenticates pending resident',
    () async {
      final storage = TestTokenStorage();
      final sessionManager = AuthSessionManager(tokenStorage: storage);
      final expiredHandler = SessionExpiredHandler();
      final controller = AuthController(
        authService: _SuccessfulRegistrationAuthService(),
        sessionManager: sessionManager,
        sessionExpiredHandler: expiredHandler,
      );
      addTearDown(() async {
        controller.dispose();
        await sessionManager.dispose();
        await expiredHandler.dispose();
      });

      final succeeded = await controller.register(
        RegistrationRequest(
          email: 'resident@example.test',
          password: 'Password123!',
          fullName: 'Juan Dela Cruz',
          birthdate: DateTime(1998, 5, 4),
          barangayId: 7,
          completeAddress: 'Block 1, Lot 2',
        ),
      );

      expect(succeeded, isTrue);
      expect(storage.tokens?.accessToken, 'signup-access');
      expect(controller.state.status, AuthenticationStatus.authenticated);
      expect(
        controller.state.user?.approvalStatus,
        ResidentApprovalStatus.pending,
      );
    },
  );

  testWidgets('Login opens signup and required fields are validated', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthTestHarness(hasSession: false);
    await auth.controller.initialize();
    addTearDown(auth.dispose);
    final router = createAppRouter(authController: auth.controller);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => auth.controller),
          authServiceProvider.overrideWith((ref) => _BarangayAuthService()),
          connectivityStatusProvider.overrideWithValue(
            const AsyncData(ConnectivityStatus.online),
          ),
        ],
        child: EkolekApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsOneWidget);
    expect(find.text('Join E-KOLEK'), findsOneWidget);
    expect(find.text('Submit registration'), findsOneWidget);

    await tester.ensureVisible(find.text('Submit registration'));
    await tester.tap(find.text('Submit registration'));
    await tester.pump();
    expect(find.text('Full name is required.'), findsOneWidget);
    expect(find.text('Birthdate is required.'), findsOneWidget);
    expect(find.text('Barangay is required.'), findsOneWidget);
    expect(find.text('Complete address is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });
}

class _BarangayAuthService extends AuthService {
  _BarangayAuthService()
    : super(apiClient: ApiClient(config: AppConfig(enableNetworkLogs: false)));

  @override
  Future<List<BarangayOption>> getActiveBarangays({cancelToken}) async =>
      const [BarangayOption(id: 7, name: 'San Vicente')];
}

class _SuccessfulRegistrationAuthService extends AuthService {
  _SuccessfulRegistrationAuthService()
    : super(apiClient: ApiClient(config: AppConfig(enableNetworkLogs: false)));

  @override
  Future<LoginResult> register(
    RegistrationRequest request, {
    cancelToken,
    onSendProgress,
  }) async => LoginResult(
    tokens: AuthTokens(
      accessToken: 'signup-access',
      refreshToken: 'signup-refresh',
    ),
  );

  @override
  Future<AuthUser> getCurrentUser({cancelToken}) async => const AuthUser(
    id: 10,
    email: 'resident@example.test',
    fullName: 'Juan Dela Cruz',
    role: UserRole.resident,
    approvalStatus: ResidentApprovalStatus.pending,
    residentProfileId: 11,
  );
}

class _SignupContractAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final barangays = options.path == ApiEndpoints.activeBarangays;
    final body = barangays
        ? {
            'success': true,
            'message': 'Active barangays retrieved successfully.',
            'data': [
              {'id': 7, 'name': 'San Vicente', 'district_or_area': ''},
            ],
          }
        : {
            'success': true,
            'message': 'Resident registration submitted successfully.',
            'data': {
              'user': {
                'id': 10,
                'email': 'resident@example.test',
                'role': 'RESIDENT',
              },
              'resident': {'id': 11, 'approval_status': 'PENDING'},
              'tokens': {
                'access': 'signup-access',
                'refresh': 'signup-refresh',
              },
            },
          };
    return ResponseBody.fromString(
      jsonEncode(body),
      barangays ? 200 : 201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
