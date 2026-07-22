import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/auth_session_manager.dart';
import '../auth/auth_tokens.dart';
import '../auth/session_expired_handler.dart';
import '../auth/token_refresh_service.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'auth_request_options.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AppConfig config,
    required AuthSessionManager sessionManager,
    required TokenRefreshService refreshService,
    required SessionExpiredHandler sessionExpiredHandler,
  }) : _apiBaseUri = Uri.parse(config.apiBaseUrl),
       _sessionManager = sessionManager,
       _refreshService = refreshService,
       _sessionExpiredHandler = sessionExpiredHandler;

  final Uri _apiBaseUri;
  final AuthSessionManager _sessionManager;
  final TokenRefreshService _refreshService;
  final SessionExpiredHandler _sessionExpiredHandler;
  Dio? _dio;
  Future<AuthTokens>? _refreshInFlight;

  void attachTo(Dio dio) {
    _dio ??= dio;
    if (!identical(_dio, dio)) {
      throw StateError('AuthInterceptor cannot be shared across Dio clients.');
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (AuthRequestOptions.requiresAuth(options) &&
        !AuthRequestOptions.skipsRefresh(options) &&
        _isTrusted(options.uri)) {
      final accessToken = await _sessionManager.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        !AuthRequestOptions.requiresAuth(request) ||
        AuthRequestOptions.skipsRefresh(request) ||
        AuthRequestOptions.refreshAttempted(request) ||
        !_isTrusted(request.uri)) {
      handler.next(err);
      return;
    }

    final currentAccessToken = await _sessionManager.getAccessToken();
    final failedAuthorization = request.headers['Authorization'];
    if (currentAccessToken != null &&
        failedAuthorization != 'Bearer $currentAccessToken') {
      if (!_isSafelyReplayable(request)) {
        handler.next(err);
        return;
      }
      final dio = _dio;
      if (dio == null) {
        handler.next(err);
        return;
      }
      request.extra[AuthRequestOptions.tokenRefreshAttempted] = true;
      request.headers['Authorization'] = 'Bearer $currentAccessToken';
      try {
        handler.resolve(await dio.fetch<Object?>(request));
      } on DioException catch (retryError) {
        handler.next(retryError);
      }
      return;
    }

    final refreshToken = await _sessionManager.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final tokens = await _refreshSingleFlight(refreshToken);
      if (!_isSafelyReplayable(request)) {
        handler.reject(
          DioException(
            requestOptions: request,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: const UnauthorizedException(
              message: 'Your session was renewed. Please retry this action.',
            ),
          ),
        );
        return;
      }

      final dio = _dio;
      if (dio == null) {
        throw StateError('AuthInterceptor is not attached to a Dio client.');
      }
      request.extra[AuthRequestOptions.tokenRefreshAttempted] = true;
      request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      final response = await dio.fetch<Object?>(request);
      handler.resolve(response);
    } on AppException catch (error) {
      if (error is UnauthorizedException || error is ForbiddenException) {
        await _sessionManager.expireSession();
        _sessionExpiredHandler.notifyExpired();
      }
      handler.reject(
        DioException(
          requestOptions: request,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: error is UnauthorizedException
              ? error
              : const UnauthorizedException(),
        ),
      );
    } on Object {
      handler.reject(
        DioException(
          requestOptions: request,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: const UnauthorizedException(),
        ),
      );
    }
  }

  Future<AuthTokens> _refreshSingleFlight(String refreshToken) {
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) return activeRefresh;

    _sessionManager.markRefreshing();
    late final Future<AuthTokens> refreshFuture;
    refreshFuture = _refreshService
        .refresh(refreshToken)
        .then((tokens) async {
          await _sessionManager.updateTokens(tokens);
          _sessionExpiredHandler.reset();
          return tokens;
        })
        .whenComplete(() {
          if (identical(_refreshInFlight, refreshFuture)) {
            _refreshInFlight = null;
          }
        });
    _refreshInFlight = refreshFuture;
    return refreshFuture;
  }

  bool _isTrusted(Uri uri) =>
      uri.scheme == _apiBaseUri.scheme &&
      uri.host == _apiBaseUri.host &&
      uri.port == _apiBaseUri.port &&
      uri.path.startsWith(_apiBaseUri.path);

  bool _isSafelyReplayable(RequestOptions request) {
    if (request.data is FormData || request.data is Stream) return false;
    return const {
      'GET',
      'HEAD',
      'OPTIONS',
    }.contains(request.method.toUpperCase());
  }
}
