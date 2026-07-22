import 'package:dio/dio.dart';

import '../api/auth_request_options.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import 'auth_tokens.dart';

class TokenRefreshService {
  TokenRefreshService({required AppConfig config, Dio? dio})
    : _config = config,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: config.apiBaseUrl,
              connectTimeout: config.connectTimeout,
              receiveTimeout: config.receiveTimeout,
              sendTimeout: config.sendTimeout,
              headers: const {Headers.acceptHeader: Headers.jsonContentType},
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
            ),
          );

  final AppConfig _config;
  final Dio _dio;

  Future<AuthTokens> refresh(
    String refreshToken, {
    CancelToken? cancelToken,
  }) async {
    if (_config.authRefreshPath.isEmpty) {
      throw const UnknownAppException(
        message: 'Session refresh is not configured.',
        developerMessage: 'AUTH_REFRESH_PATH is empty.',
      );
    }
    try {
      final response = await _dio.post<Object?>(
        _config.authRefreshPath,
        data: {'refresh': refreshToken},
        options: AuthRequestOptions.public(),
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data is! Map) {
        throw InvalidResponseException(
          statusCode: response.statusCode,
          developerMessage: 'Refresh response was not a JSON object.',
        );
      }
      final access = data['access'];
      final rotatedRefresh = data['refresh'];
      if (access is! String || access.trim().isEmpty) {
        throw InvalidResponseException(
          statusCode: response.statusCode,
          developerMessage: 'Refresh response did not contain access.',
        );
      }
      if (rotatedRefresh is! String || rotatedRefresh.trim().isEmpty) {
        throw InvalidResponseException(
          statusCode: response.statusCode,
          developerMessage:
              'Rotating refresh response did not contain refresh.',
        );
      }
      return AuthTokens(accessToken: access, refreshToken: rotatedRefresh);
    } on DioException catch (error) {
      throw ErrorHandler.handle(error);
    }
  }
}
