import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../models/account_status_info.dart';

class AccountStatusService {
  AccountStatusService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<AccountStatusInfo> getCurrentStatus({CancelToken? cancelToken}) async {
    final response = await _apiClient.get<Object?>(
      ApiEndpoints.currentUser,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final envelope = _map(response.data);
    final data = _map(envelope?['data']);
    if (data == null) {
      throw InvalidResponseException(statusCode: response.statusCode);
    }
    try {
      return AccountStatusInfo.fromCurrentUserData(data);
    } on FormatException catch (error) {
      throw InvalidResponseException(
        statusCode: response.statusCode,
        developerMessage: error.message,
        originalError: error,
      );
    }
  }

  static Map<String, Object?>? _map(Object? value) => value is Map
      ? value.map((key, item) => MapEntry(key.toString(), item))
      : null;
}
