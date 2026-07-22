import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../models/barangay_leaderboard_entry.dart';
import '../models/current_rank.dart';
import '../models/leaderboard_metric.dart';
import '../models/leaderboard_page.dart';
import '../models/leaderboard_period.dart';
import '../models/leaderboard_scope.dart';
import '../models/resident_leaderboard_entry.dart';

class LeaderboardService {
  LeaderboardService(this._client);
  final ApiClient _client;
  Future<LeaderboardPage<ResidentLeaderboardEntry>> getResidents({
    int page = 1,
    CancelToken? cancelToken,
  }) => _page(
    ApiEndpoints.leaderboard,
    page,
    ResidentLeaderboardEntry.fromJson,
    cancelToken,
  );
  Future<LeaderboardPage<BarangayLeaderboardEntry>> getBarangays({
    int page = 1,
    CancelToken? cancelToken,
  }) => _page(
    ApiEndpoints.barangayLeaderboard,
    page,
    BarangayLeaderboardEntry.fromJson,
    cancelToken,
  );
  Future<CurrentRank> getCurrentResidentRank({CancelToken? cancelToken}) =>
      _rank(ApiEndpoints.currentResidentRank, cancelToken);
  Future<CurrentRank> getCurrentBarangayRank({CancelToken? cancelToken}) =>
      _rank(ApiEndpoints.currentBarangayRank, cancelToken);
  Future<LeaderboardPage<T>> _page<T>(
    String path,
    int page,
    T Function(Map<String, Object?>) parse,
    CancelToken? cancelToken,
  ) async {
    final response = await _client.get<Object?>(
      path,
      queryParameters: {'page': page, 'page_size': 20},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final data = _data(response.data), results = data['results'];
    if (results is! List) throw const InvalidResponseException();
    return LeaderboardPage(
      items: results
          .whereType<Map>()
          .map((item) => parse(_map(item)))
          .toList(growable: false),
      count: data['count'] as int? ?? results.length,
      hasNext: data['next'] != null,
      scope: LeaderboardScope.fromJson(data['scope']),
      scopeLabel: data['scope_label'] as String? ?? '',
      metric: LeaderboardMetric.fromJson(data['metric']),
      scoreLabel: data['score_label'] as String? ?? 'Verified score',
      scoreUnit: data['score_unit'] as String? ?? '',
      period: LeaderboardPeriod.fromJson(data['period']),
      enabled: data['enabled'] == true,
      updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? ''),
    );
  }

  Future<CurrentRank> _rank(String path, CancelToken? cancelToken) async {
    final response = await _client.get<Object?>(
      path,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return CurrentRank.fromJson(_data(response.data));
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
