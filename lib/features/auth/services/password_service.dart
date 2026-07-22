import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';

class PasswordService {
  PasswordService(this._client);
  final ApiClient _client;
  Future<void> requestReset(String email, {CancelToken? cancelToken}) async {
    await _client.post<Object?>(
      ApiEndpoints.passwordResetRequest,
      data: {'email': email},
      options: AuthRequestOptions.public(),
      cancelToken: cancelToken,
    );
  }

  Future<String> verifyCode(
    String email,
    String code, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.post<Object?>(
      ApiEndpoints.passwordResetVerify,
      data: {'email': email, 'code': code},
      options: AuthRequestOptions.public(),
      cancelToken: cancelToken,
    );
    final root = response.data;
    final data = root is Map ? root['data'] : null;
    final ticket = data is Map ? data['reset_ticket'] : null;
    if (ticket is! String || ticket.isEmpty) {
      throw const InvalidResponseException();
    }
    return ticket;
  }

  Future<void> confirmReset(
    String ticket,
    String password,
    String confirmation, {
    CancelToken? cancelToken,
  }) async {
    await _client.post<Object?>(
      ApiEndpoints.passwordResetConfirm,
      data: {
        'reset_ticket': ticket,
        'new_password': password,
        'password_confirmation': confirmation,
      },
      options: AuthRequestOptions.public(),
      cancelToken: cancelToken,
    );
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword, {
    CancelToken? cancelToken,
  }) async {
    await _client.post<Object?>(
      ApiEndpoints.changePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
  }
}
