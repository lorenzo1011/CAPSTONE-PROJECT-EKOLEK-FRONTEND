import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ekolek_app/core/api/api_client.dart';
import 'package:ekolek_app/core/api/auth_interceptor.dart';
import 'package:ekolek_app/core/api/auth_request_options.dart';
import 'package:ekolek_app/core/auth/auth_session.dart';
import 'package:ekolek_app/core/auth/auth_session_manager.dart';
import 'package:ekolek_app/core/auth/auth_tokens.dart';
import 'package:ekolek_app/core/auth/jwt_utils.dart';
import 'package:ekolek_app/core/auth/session_expired_handler.dart';
import 'package:ekolek_app/core/auth/token_refresh_service.dart';
import 'package:ekolek_app/core/config/app_config.dart';
import 'package:ekolek_app/core/errors/app_exception.dart';
import 'package:ekolek_app/core/storage/token_storage.dart';
import 'package:ekolek_app/shared/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2030, 1, 1);

  AuthTokens tokens({
    String access = 'access-token',
    String refresh = 'refresh-token',
    DateTime? accessExpiry,
    DateTime? refreshExpiry,
  }) => AuthTokens(
    accessToken: access,
    refreshToken: refresh,
    accessTokenExpiresAt: accessExpiry ?? now.add(const Duration(minutes: 5)),
    refreshTokenExpiresAt: refreshExpiry ?? now.add(const Duration(days: 1)),
  );

  group('AuthTokens and JwtUtils', () {
    test('detects valid and expired access tokens', () {
      expect(tokens().isAccessTokenExpired(now: now), isFalse);
      expect(
        tokens(
          accessExpiry: now.subtract(const Duration(seconds: 1)),
        ).isAccessTokenExpired(now: now),
        isTrue,
      );
    });

    test('applies expiration leeway', () {
      final value = tokens(accessExpiry: now.add(const Duration(seconds: 20)));
      expect(value.isAccessTokenExpired(now: now), isTrue);
      expect(
        value.isAccessTokenExpired(now: now, leeway: Duration.zero),
        isFalse,
      );
    });

    test('never exposes token values through toString', () {
      final value = tokens(
        access: 'very-secret-access',
        refresh: 'secret-refresh',
      );
      expect(value.toString(), isNot(contains('very-secret-access')));
      expect(value.toString(), isNot(contains('secret-refresh')));
    });

    test('reads a valid exp claim', () {
      final expiration = DateTime.utc(2032, 2, 3);
      final token = _jwtWithExpiration(expiration);
      expect(JwtUtils.expiration(token), expiration);
    });

    test('safely rejects malformed JWT values', () {
      expect(JwtUtils.expiration('not-a-jwt'), isNull);
      expect(JwtUtils.expiration('a.b.c'), isNull);
      expect(JwtUtils.expiration(''), isNull);
    });
  });

  group('AuthSessionManager', () {
    test('initializes as unauthenticated when storage is empty', () async {
      final manager = AuthSessionManager(tokenStorage: _MemoryTokenStorage());
      addTearDown(manager.dispose);
      expect(
        (await manager.initialize()).status,
        AuthSessionStatus.unauthenticated,
      );
    });

    test('initializes authenticated when access token is valid', () async {
      final storage = _MemoryTokenStorage(tokens());
      final manager = AuthSessionManager(tokenStorage: storage);
      addTearDown(manager.dispose);
      expect(
        (await manager.initialize()).status,
        AuthSessionStatus.authenticated,
      );
    });

    test(
      'expired access with usable refresh remains refresh-capable',
      () async {
        final storage = _MemoryTokenStorage(
          tokens(
            accessExpiry: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
            refreshExpiry: DateTime.now().toUtc().add(const Duration(days: 1)),
          ),
        );
        final manager = AuthSessionManager(tokenStorage: storage);
        addTearDown(manager.dispose);
        final session = await manager.initialize();
        expect(session.status, AuthSessionStatus.authenticated);
        expect(session.canRefresh, isTrue);
      },
    );

    test('expired refresh clears the session', () async {
      final storage = _MemoryTokenStorage(
        tokens(
          accessExpiry: DateTime.now().toUtc().subtract(
            const Duration(minutes: 2),
          ),
          refreshExpiry: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        ),
      );
      final manager = AuthSessionManager(tokenStorage: storage);
      addTearDown(manager.dispose);
      expect((await manager.initialize()).status, AuthSessionStatus.expired);
      expect(storage.value, isNull);
    });

    test('saving and clearing a session updates storage', () async {
      final storage = _MemoryTokenStorage();
      final manager = AuthSessionManager(tokenStorage: storage);
      addTearDown(manager.dispose);
      await manager.saveAuthenticatedSession(tokens());
      expect(storage.value, isNotNull);
      await manager.clearSession();
      expect(storage.value, isNull);
      expect(manager.session.status, AuthSessionStatus.unauthenticated);
    });
  });

  group('AuthInterceptor', () {
    test('attaches Bearer token to authenticated trusted requests', () async {
      final harness = _AuthHarness(initialTokens: tokens());
      addTearDown(harness.dispose);
      await harness.client.get<Object?>(
        'mobile/test/',
        options: AuthRequestOptions.authenticated(),
      );
      expect(
        harness.adapter.requests.single.headers['Authorization'],
        'Bearer access-token',
      );
    });

    test('does not attach a token to public requests', () async {
      final harness = _AuthHarness(initialTokens: tokens());
      addTearDown(harness.dispose);
      await harness.client.get<Object?>(
        'auth/login/',
        options: AuthRequestOptions.public(),
      );
      expect(harness.adapter.requests.single.headers['Authorization'], isNull);
    });

    test('does not attach a token to an external host', () async {
      final harness = _AuthHarness(initialTokens: tokens());
      addTearDown(harness.dispose);
      await harness.client.get<Object?>(
        'https://external.example/resource',
        options: AuthRequestOptions.authenticated(),
      );
      expect(harness.adapter.requests.single.headers['Authorization'], isNull);
    });

    test('does not refresh requests marked to skip refresh', () async {
      final harness = _AuthHarness(
        initialTokens: tokens(),
        alwaysUnauthorized: true,
      );
      addTearDown(harness.dispose);
      await expectLater(
        harness.client.get<Object?>(
          'mobile/test/',
          options: AuthRequestOptions.authenticated(skipRefresh: true),
        ),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(harness.refreshService.calls, 0);
    });

    test(
      'successful refresh updates storage and retries with the new token',
      () async {
        final harness = _AuthHarness(
          initialTokens: tokens(),
          refreshResult: tokens(access: 'new-access', refresh: 'new-refresh'),
          rejectOldAccess: true,
        );
        addTearDown(harness.dispose);
        await harness.client.get<Object?>(
          'mobile/test/',
          options: AuthRequestOptions.authenticated(),
        );
        expect(harness.refreshService.calls, 1);
        expect(harness.storage.value?.accessToken, 'new-access');
        expect(
          harness.adapter.requests.last.headers['Authorization'],
          'Bearer new-access',
        );
        expect(harness.adapter.requests.length, 2);
      },
    );

    test('multiple simultaneous 401 responses use one refresh', () async {
      final completer = Completer<AuthTokens>();
      final harness = _AuthHarness(
        initialTokens: tokens(),
        refreshCompleter: completer,
        rejectOldAccess: true,
      );
      addTearDown(harness.dispose);
      final requests = [
        harness.client.get<Object?>(
          'mobile/a/',
          options: AuthRequestOptions.authenticated(),
        ),
        harness.client.get<Object?>(
          'mobile/b/',
          options: AuthRequestOptions.authenticated(),
        ),
      ];
      await Future<void>.delayed(Duration.zero);
      completer.complete(tokens(access: 'new-access', refresh: 'new-refresh'));
      await Future.wait(requests);
      expect(harness.refreshService.calls, 1);
      expect(
        harness.adapter.requests.where(
          (request) => request.headers['Authorization'] == 'Bearer new-access',
        ),
        hasLength(2),
      );
    });

    test(
      'failed rejected refresh clears session and returns safe unauthorized',
      () async {
        final harness = _AuthHarness(
          initialTokens: tokens(),
          refreshError: const UnauthorizedException(),
          alwaysUnauthorized: true,
        );
        addTearDown(harness.dispose);
        await expectLater(
          harness.client.get<Object?>(
            'mobile/test/',
            options: AuthRequestOptions.authenticated(),
          ),
          throwsA(isA<UnauthorizedException>()),
        );
        expect(harness.storage.value, isNull);
        expect(harness.manager.session.status, AuthSessionStatus.expired);
      },
    );

    test('retried requests do not enter an infinite loop', () async {
      final harness = _AuthHarness(
        initialTokens: tokens(),
        refreshResult: tokens(access: 'new-access', refresh: 'new-refresh'),
        alwaysUnauthorized: true,
      );
      addTearDown(harness.dispose);
      await expectLater(
        harness.client.get<Object?>(
          'mobile/test/',
          options: AuthRequestOptions.authenticated(),
        ),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(harness.adapter.requests.length, 2);
      expect(harness.refreshService.calls, 1);
    });

    test('unsafe multipart requests are not duplicated', () async {
      final harness = _AuthHarness(
        initialTokens: tokens(),
        refreshResult: tokens(access: 'new-access', refresh: 'new-refresh'),
        alwaysUnauthorized: true,
      );
      addTearDown(harness.dispose);
      await expectLater(
        harness.client.post<Object?>(
          'mobile/upload/',
          data: FormData.fromMap({'image': 'content'}),
          options: AuthRequestOptions.authenticated(),
        ),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(harness.adapter.requests.length, 1);
      expect(harness.refreshService.calls, 1);
    });
  });

  test('auth providers support fake TokenStorage overrides', () {
    final fake = _MemoryTokenStorage();
    final container = ProviderContainer(
      overrides: [tokenStorageProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    expect(container.read(tokenStorageProvider), same(fake));
  });

  test('startup config accepts an empty optional refresh path', () {
    expect(() => AppConfig(authRefreshPath: ''), returnsNormally);
  });

  test('refresh fails safely when no refresh path is configured', () async {
    final service = TokenRefreshService(config: AppConfig(authRefreshPath: ''));
    await expectLater(
      service.refresh('opaque-refresh'),
      throwsA(isA<UnknownAppException>()),
    );
  });
}

String _jwtWithExpiration(DateTime expiration) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'none'})}.${encode({'exp': expiration.millisecondsSinceEpoch ~/ 1000})}.signature';
}

class _MemoryTokenStorage implements TokenStorage {
  _MemoryTokenStorage([this.value]);
  AuthTokens? value;

  @override
  Future<void> clearTokens() async => value = null;
  @override
  Future<bool> hasTokens() async => value != null;
  @override
  Future<String?> readAccessToken() async => value?.accessToken;
  @override
  Future<String?> readRefreshToken() async => value?.refreshToken;
  @override
  Future<AuthTokens?> readTokens() async => value;
  @override
  Future<void> saveTokens(AuthTokens tokens) async => value = tokens;
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({
    this.rejectOldAccess = false,
    this.alwaysUnauthorized = false,
  });
  final bool rejectOldAccess;
  final bool alwaysUnauthorized;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      options.copyWith(headers: Map<String, Object?>.from(options.headers)),
    );
    final authorization = options.headers['Authorization'];
    final unauthorized =
        alwaysUnauthorized ||
        (rejectOldAccess && authorization == 'Bearer access-token');
    return ResponseBody.fromString(
      unauthorized ? '{"detail":"unauthorized"}' : '{"ok":true}',
      unauthorized ? 401 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeRefreshService extends TokenRefreshService {
  _FakeRefreshService({
    required super.config,
    this.result,
    this.error,
    this.completer,
  });
  final AuthTokens? result;
  final AppException? error;
  final Completer<AuthTokens>? completer;
  int calls = 0;

  @override
  Future<AuthTokens> refresh(
    String refreshToken, {
    CancelToken? cancelToken,
  }) async {
    calls++;
    if (error != null) throw error!;
    if (completer != null) return completer!.future;
    return result!;
  }
}

class _AuthHarness {
  _AuthHarness({
    required AuthTokens initialTokens,
    AuthTokens? refreshResult,
    AppException? refreshError,
    Completer<AuthTokens>? refreshCompleter,
    bool rejectOldAccess = false,
    bool alwaysUnauthorized = false,
  }) : config = AppConfig(enableNetworkLogs: false),
       storage = _MemoryTokenStorage(initialTokens),
       adapter = _RecordingAdapter(
         rejectOldAccess: rejectOldAccess,
         alwaysUnauthorized: alwaysUnauthorized,
       ) {
    manager = AuthSessionManager(tokenStorage: storage);
    expiredHandler = SessionExpiredHandler();
    refreshService = _FakeRefreshService(
      config: config,
      result: refreshResult ?? initialTokens,
      error: refreshError,
      completer: refreshCompleter,
    );
    final interceptor = AuthInterceptor(
      config: config,
      sessionManager: manager,
      refreshService: refreshService,
      sessionExpiredHandler: expiredHandler,
    );
    client = ApiClient(config: config, authInterceptor: interceptor);
    client.dio.httpClientAdapter = adapter;
  }

  final AppConfig config;
  final _MemoryTokenStorage storage;
  final _RecordingAdapter adapter;
  late final AuthSessionManager manager;
  late final SessionExpiredHandler expiredHandler;
  late final _FakeRefreshService refreshService;
  late final ApiClient client;

  Future<void> dispose() async {
    await manager.dispose();
    await expiredHandler.dispose();
    client.dio.close(force: true);
  }
}
