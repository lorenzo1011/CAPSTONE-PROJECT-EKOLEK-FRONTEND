import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/collection_transaction.dart';
import '../models/recyclable_material.dart';

class RecyclingService {
  RecyclingService(this._client);
  final ApiClient _client;
  Future<PaginatedResponse<CollectionTransaction>> history({
    int page = 1,
    String? status,
    CancelToken? cancelToken,
  }) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.recycling,
      queryParameters: {'page': page, 'status': ?status},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final d = _map(r.data), list = d['results'];
    if (list is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: d['count'] as int,
      items: list
          .whereType<Map>()
          .map(
            (e) => CollectionTransaction.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(),
      hasNext: d['next'] != null,
    );
  }

  Future<CollectionTransaction> detail(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.recyclingDetail(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return CollectionTransaction.fromJson(_map(r.data));
  }

  Future<List<RecyclableMaterial>> materials({CancelToken? cancelToken}) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.materials,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final d = r.data is Map ? (r.data as Map)['data'] : null;
    if (d is! List) throw const InvalidResponseException();
    return d
        .whereType<Map>()
        .map(
          (e) => RecyclableMaterial.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();
  }

  Map<String, Object?> _map(Object? raw) {
    final d = raw is Map ? raw['data'] : null;
    if (d is! Map) throw const InvalidResponseException();
    return d.map((k, v) => MapEntry(k.toString(), v));
  }
}
