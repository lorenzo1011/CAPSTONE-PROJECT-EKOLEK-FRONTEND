import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/daily_game_progress.dart';
import '../models/eco_game.dart';
import '../models/game_attempt.dart';

class GamesService {
  GamesService(this._client);
  final ApiClient _client;
  Future<PaginatedResponse<EcoGame>> getGames({
    int page = 1,
    int pageSize = 20,
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.games,
      queryParameters: {'page': page, 'page_size': pageSize},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final data = _data(response.data);
    final raw = data['results'];
    if (raw is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: data['count'] as int? ?? raw.length,
      items: raw
          .whereType<Map>()
          .map((item) => EcoGame.fromJson(_map(item)))
          .toList(),
      hasNext: data['next'] != null,
    );
  }

  Future<EcoGame> getGame(int id, {CancelToken? cancelToken}) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.game(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return EcoGame.fromJson(_data(response.data));
  }

  Future<DailyGameProgress> getDailyProgress({CancelToken? cancelToken}) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.dailyGameProgress,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return DailyGameProgress.fromJson(_data(response.data));
  }

  Future<PaginatedResponse<GameAttempt>> getRecentAttempts({
    int page = 1,
    int pageSize = 5,
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.gameAttempts,
      queryParameters: {'page': page, 'page_size': pageSize},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final data = _data(response.data);
    final raw = data['results'];
    if (raw is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: data['count'] as int? ?? raw.length,
      items: raw
          .whereType<Map>()
          .map((item) => GameAttempt.fromJson(_map(item)))
          .toList(),
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
