import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

typedef NetworkLogWriter = void Function(String message);

class NetworkLogInterceptor extends Interceptor {
  NetworkLogInterceptor({required AppConfig config, NetworkLogWriter? writer})
    : _enabled = config.enableNetworkLogs && !config.isProduction,
      _writer = writer ?? debugPrint;

  static const _startedAtKey = 'network_log_started_at';
  static const _sensitiveKeys = {
    'password',
    'password_confirmation',
    'access',
    'refresh',
    'token',
    'authorization',
    'valid_id',
    'profile_photo',
  };

  final bool _enabled;
  final NetworkLogWriter _writer;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_enabled) {
      options.extra[_startedAtKey] = DateTime.now();
      _writer('[API] ${options.method} ${safeRequestUrl(options)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_enabled) {
      _writer(
        '[API] ${response.statusCode ?? 'unknown'} '
        '${response.requestOptions.method} '
        '${safeRequestUrl(response.requestOptions)} '
        '(${_duration(response.requestOptions)})',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_enabled) {
      _writer(
        '[API] error ${err.response?.statusCode ?? err.type.name} '
        '${err.requestOptions.method} ${safeRequestUrl(err.requestOptions)} '
        '(${_duration(err.requestOptions)})',
      );
    }
    handler.next(err);
  }

  String _duration(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];
    if (startedAt is! DateTime) return 'duration unavailable';
    return '${DateTime.now().difference(startedAt).inMilliseconds}ms';
  }

  static String safeRequestUrl(RequestOptions options) {
    final uri = options.uri.replace(queryParameters: const {});
    return uri.toString();
  }

  @visibleForTesting
  static Object? sanitizeForLog(Object? value) {
    if (value == null) return null;
    if (value is FormData || value is MultipartFile || value is List<int>) {
      return '[binary data omitted]';
    }
    if (value is Map) {
      return value.map<String, Object?>((key, item) {
        final normalizedKey = key.toString().toLowerCase();
        final sensitive = _sensitiveKeys.any(
          (sensitiveKey) => normalizedKey.contains(sensitiveKey),
        );
        return MapEntry(
          key.toString(),
          sensitive ? '[REDACTED]' : sanitizeForLog(item),
        );
      });
    }
    if (value is Iterable) {
      return value.map(sanitizeForLog).toList(growable: false);
    }
    final text = value.toString();
    return text.length > 500 ? '${text.substring(0, 500)}…' : value;
  }
}
