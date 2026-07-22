import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../models/digital_resident_id.dart';

class ResidentIdService {
  ResidentIdService(this._client);
  final ApiClient _client;
  Future<DigitalResidentId> getDigitalResidentId({
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.digitalResidentId,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final root = response.data;
    final data = root is Map ? root['data'] : null;
    if (data is! Map) throw const InvalidResponseException();
    return DigitalResidentId.fromJson(
      data.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}
