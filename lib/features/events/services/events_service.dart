import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/resident_event.dart';

class EventsService {
  EventsService(this._client);
  final ApiClient _client;
  Future<PaginatedResponse<ResidentEvent>> collection({
    int page = 1,
    CancelToken? cancelToken,
  }) => _list(
    ApiEndpoints.collectionEvents,
    ResidentEventType.collection,
    page,
    cancelToken,
  );
  Future<PaginatedResponse<ResidentEvent>> rewards({
    int page = 1,
    CancelToken? cancelToken,
  }) => _list(
    ApiEndpoints.rewardEvents,
    ResidentEventType.rewardDistribution,
    page,
    cancelToken,
  );
  Future<ResidentEvent> detail(
    int id,
    ResidentEventType type, {
    CancelToken? cancelToken,
  }) async {
    final path = type == ResidentEventType.collection
        ? ApiEndpoints.collectionEvent(id)
        : ApiEndpoints.rewardEvent(id);
    final r = await _client.get<Object?>(
      path,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return ResidentEvent.fromJson(_data(r.data), type);
  }

  Future<PaginatedResponse<ResidentEvent>> _list(
    String path,
    ResidentEventType type,
    int page,
    CancelToken? token,
  ) async {
    final r = await _client.get<Object?>(
      path,
      queryParameters: {'page': page},
      options: AuthRequestOptions.authenticated(),
      cancelToken: token,
    );
    final d = _data(r.data), raw = d['results'];
    if (raw is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: d['count'] as int,
      items: raw
          .whereType<Map>()
          .map(
            (e) => ResidentEvent.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
              type,
            ),
          )
          .toList(),
      hasNext: d['next'] != null,
    );
  }

  Map<String, Object?> _data(Object? raw) {
    final x = raw is Map ? raw['data'] : null;
    if (x is! Map) throw const InvalidResponseException();
    return x.map((k, v) => MapEntry(k.toString(), v));
  }
}
