import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/eco_challenge.dart';

class ChallengesService {
  ChallengesService(this._client);
  final ApiClient _client;

  Future<PaginatedResponse<EcoChallenge>> getChallenges({
    int page = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) => _page(ApiEndpoints.challenges, page, pageSize, cancelToken);

  Future<PaginatedResponse<EcoChallenge>> getHistory({
    int page = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) => _page(ApiEndpoints.challengeProgress, page, pageSize, cancelToken);

  Future<EcoChallenge> getChallenge(int id, {CancelToken? cancelToken}) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.challenge(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return EcoChallenge.fromJson(_data(response.data));
  }

  Future<PaginatedResponse<EcoChallenge>> _page(
    String path,
    int page,
    int pageSize,
    CancelToken? cancelToken,
  ) async {
    final response = await _client.get<Object?>(
      path,
      queryParameters: {'page': page, 'page_size': pageSize},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final data = _data(response.data);
    final results = data['results'];
    if (results is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: data['count'] as int? ?? results.length,
      items: results
          .whereType<Map>()
          .map((item) => EcoChallenge.fromJson(_map(item)))
          .toList(growable: false),
      hasNext: data['next'] != null,
    );
  }

  static Map<String, Object?> _data(Object? raw) {
    if (raw is! Map || raw['data'] is! Map) {
      throw const InvalidResponseException();
    }
    return _map(raw['data'] as Map);
  }

  static Map<String, Object?> _map(Map raw) =>
      raw.map((key, value) => MapEntry(key.toString(), value));
}
