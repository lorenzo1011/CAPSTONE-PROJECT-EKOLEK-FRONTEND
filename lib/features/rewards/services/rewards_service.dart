import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../../events/models/resident_event.dart';
import '../models/redemption_eligibility.dart';
import '../models/redemption_preview.dart';
import '../models/reward_category.dart';
import '../models/reward_item.dart';

class RewardsService {
  RewardsService(this._client);
  final ApiClient _client;
  Future<PaginatedResponse<RewardItem>> getRewards({
    int page = 1,
    String? search,
    String? category,
    CancelToken? cancelToken,
  }) async {
    final q = <String, Object?>{'page': page};
    if (search?.isNotEmpty == true) q['search'] = search;
    if (category?.isNotEmpty == true) q['category'] = category;
    final r = await _client.get<Object?>(
      ApiEndpoints.rewards,
      queryParameters: q,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final d = _data(r.data), raw = d['results'];
    if (raw is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: d['count'] as int? ?? raw.length,
      items: raw
          .whereType<Map>()
          .map((x) => RewardItem.fromJson(_map(x)))
          .toList(),
      hasNext: d['next'] != null,
    );
  }

  Future<List<RewardCategory>> getCategories({CancelToken? cancelToken}) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.rewardCategories,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final raw = _rootData(r.data);
    if (raw is! List) throw const InvalidResponseException();
    return raw
        .whereType<Map>()
        .map((x) => RewardCategory.fromJson(_map(x)))
        .toList();
  }

  Future<RewardItem> getReward(int id, {CancelToken? cancelToken}) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.reward(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return RewardItem.fromJson(_data(r.data));
  }

  Future<RedemptionEligibility> eligibility(
    int id, {
    required int quantity,
    int? eventId,
    CancelToken? cancelToken,
  }) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.rewardEligibility(id),
      queryParameters: {'quantity': quantity, 'event_id': ?eventId},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return RedemptionEligibility.fromJson(_data(r.data));
  }

  Future<RedemptionPreview> preview(
    int id, {
    required int quantity,
    int? eventId,
    CancelToken? cancelToken,
  }) async {
    final r = await _client.post<Object?>(
      ApiEndpoints.rewardPreview(id),
      data: {'quantity': quantity, 'event_id': ?eventId},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return RedemptionPreview.fromJson(_data(r.data));
  }

  Future<List<ResidentEvent>> validEvents(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.rewardValidEvents(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final raw = _rootData(r.data);
    if (raw is! List) throw const InvalidResponseException();
    return raw
        .whereType<Map>()
        .map(
          (x) => ResidentEvent.fromJson(
            _map(x),
            ResidentEventType.rewardDistribution,
          ),
        )
        .toList();
  }

  static Object? _rootData(Object? raw) {
    if (raw is! Map) throw const InvalidResponseException();
    return raw['data'];
  }

  static Map<String, Object?> _data(Object? raw) {
    final d = _rootData(raw);
    if (d is! Map) throw const InvalidResponseException();
    return _map(d);
  }

  static Map<String, Object?> _map(Map raw) =>
      raw.map((k, v) => MapEntry(k.toString(), v));
}
