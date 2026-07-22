import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/auth/auth_tokens.dart';
import '../../../core/errors/app_exception.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/login_result.dart';

class AuthService {
  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<LoginResult> login(
    LoginRequest request, {
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.post<Object?>(
      ApiEndpoints.login,
      data: request.toJson(),
      options: AuthRequestOptions.public(),
      cancelToken: cancelToken,
    );
    final envelope = _map(response.data);
    final data = _map(envelope?['data']);
    final tokenData = _map(data?['tokens']);
    final access = tokenData?['access'];
    final refresh = tokenData?['refresh'];
    if (access is! String || refresh is! String) {
      throw InvalidResponseException(
        statusCode: response.statusCode,
        developerMessage: 'Login response tokens were missing or invalid.',
      );
    }
    return LoginResult(
      tokens: AuthTokens(accessToken: access, refreshToken: refresh),
    );
  }

  Future<AuthUser> getCurrentUser({CancelToken? cancelToken}) async {
    final response = await _apiClient.get<Object?>(
      ApiEndpoints.currentUser,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final envelope = _map(response.data);
    final data = _map(envelope?['data']);
    if (data == null) {
      throw InvalidResponseException(
        statusCode: response.statusCode,
        developerMessage: 'Current-user response data was invalid.',
      );
    }
    try {
      return AuthUser.fromCurrentUserData(data);
    } on FormatException catch (error) {
      throw InvalidResponseException(
        statusCode: response.statusCode,
        developerMessage: error.message,
        originalError: error,
      );
    }
  }

  static Map<String, Object?>? _map(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}
