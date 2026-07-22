import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/redemption_request.dart';
import '../models/redemption_request_result.dart';
import '../models/resident_redemption.dart';

class RedemptionService {
  RedemptionService(this._client);
  final ApiClient _client;
  Future<RedemptionRequestResult> submit(
    RedemptionRequest request, {
    CancelToken? cancelToken,
  }) async {
    final r = await _client.post<Object?>(
      ApiEndpoints.redemptionRequests,
      data: request.toJson(),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return RedemptionRequestResult.fromJson(_data(r.data));
  }

  Future<PaginatedResponse<ResidentRedemption>> history({
    int page = 1,
    String? status,
    CancelToken? cancelToken,
  }) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.redemptionRequests,
      queryParameters: {
        'page': page,
        ...?status == null ? null : {'status': status},
      },
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final d = _data(r.data), raw = d['results'];
    if (raw is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: d['count'] as int? ?? raw.length,
      items: raw
          .whereType<Map>()
          .map((x) => ResidentRedemption.fromJson(_map(x)))
          .toList(),
      hasNext: d['next'] != null,
    );
  }

  Future<ResidentRedemption> detail(int id, {CancelToken? cancelToken}) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.redemptionRequest(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return ResidentRedemption.fromJson(_data(r.data));
  }

  Future<ResidentRedemption> cancel(int id, {CancelToken? cancelToken}) async {
    final r = await _client.post<Object?>(
      ApiEndpoints.cancelRedemptionRequest(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return ResidentRedemption.fromJson(_data(r.data));
  }

  Future<ResidentRedemption?> lookup(
    String key, {
    CancelToken? cancelToken,
  }) async {
    final r = await _client.post<Object?>(
      ApiEndpoints.redemptionRequestLookup,
      data: {'idempotency_key': key},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final d = _data(r.data), raw = d['redemption'];
    if (d['found'] != true || raw is! Map) return null;
    return ResidentRedemption.fromJson(_map(raw));
  }

  static Map<String, Object?> _data(Object? raw) {
    if (raw is! Map || raw['data'] is! Map) {
      throw const InvalidResponseException();
    }
    return _map(raw['data'] as Map);
  }

  static Map<String, Object?> _map(Map raw) =>
      raw.map((k, v) => MapEntry(k.toString(), v));
}
