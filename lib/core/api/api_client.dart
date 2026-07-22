import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/error_handler.dart';
import 'auth_interceptor.dart';
import 'network_log_interceptor.dart';

class ApiClient {
  ApiClient({
    required AppConfig config,
    Dio? dio,
    AuthInterceptor? authInterceptor,
  }) : dio = dio ?? Dio(_baseOptions(config)) {
    if (!this.dio.interceptors.any(
      (item) => item is _RequestHeadersInterceptor,
    )) {
      this.dio.interceptors.add(_RequestHeadersInterceptor());
    }
    if (authInterceptor != null &&
        !this.dio.interceptors.contains(authInterceptor)) {
      authInterceptor.attachTo(this.dio);
      this.dio.interceptors.add(authInterceptor);
    }
    if (!this.dio.interceptors.any((item) => item is NetworkLogInterceptor)) {
      this.dio.interceptors.add(NetworkLogInterceptor(config: config));
    }

    // The authentication interceptor will be registered here in the next phase.
  }

  final Dio dio;

  static BaseOptions _baseOptions(AppConfig config) {
    return BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: const {Headers.acceptHeader: Headers.jsonContentType},
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => _guard(
    () => dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _guard(
    () => dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _guard(
    () => dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _guard(
    () => dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _guard(
    () => dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ErrorHandler.handle(error);
    }
  }
}

class _RequestHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[Headers.acceptHeader] = Headers.jsonContentType;
    if (options.data is FormData) {
      options.headers.remove(Headers.contentTypeHeader);
      options.contentType = null;
    } else {
      options.contentType ??= Headers.jsonContentType;
    }
    handler.next(options);
  }
}
