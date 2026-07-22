import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/achievement_badge.dart';
import '../models/achievement_summary.dart';

class AchievementsService {
  AchievementsService(this._client);
  final ApiClient _client;

  Future<PaginatedResponse<AchievementBadge>> getBadges({
    int page = 1,
    int pageSize = 20,
    String? type,
    CancelToken? cancelToken,
  }) async {
    final query = <String, Object?>{'page': page, 'page_size': pageSize};
    if (type != null) query['type'] = type;
    final response = await _client.get<Object?>(
      ApiEndpoints.badges,
      queryParameters: query,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final data = _data(response.data), results = data['results'];
    if (results is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: data['count'] as int? ?? results.length,
      items: results
          .whereType<Map>()
          .map((item) => AchievementBadge.fromJson(_map(item)))
          .toList(growable: false),
      hasNext: data['next'] != null,
    );
  }

  Future<AchievementSummary> getSummary({CancelToken? cancelToken}) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.badgeSummary,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return AchievementSummary.fromJson(_data(response.data));
  }

  Future<AchievementBadge> getBadge(int id, {CancelToken? cancelToken}) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.badge(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return AchievementBadge.fromJson(_data(response.data));
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
