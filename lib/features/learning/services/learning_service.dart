import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/learning_video.dart';
import '../models/video_progress.dart';

class LearningService {
  LearningService(this._client);
  final ApiClient _client;

  Future<PaginatedResponse<LearningVideo>> getLearningVideos({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? search,
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.learningVideos,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (category?.isNotEmpty == true) 'category': category,
        if (search?.isNotEmpty == true) 'search': search,
      },
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final data = _dataMap(response.data);
    final raw = data['results'];
    if (raw is! List) throw const InvalidResponseException();
    return PaginatedResponse(
      count: data['count'] as int? ?? raw.length,
      items: raw
          .whereType<Map>()
          .map((item) => LearningVideo.fromJson(_map(item)))
          .toList(),
      hasNext: data['next'] != null,
    );
  }

  Future<LearningVideo> getLearningVideoDetail(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.learningVideo(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return LearningVideo.fromJson(_dataMap(response.data));
  }

  Future<VideoProgress?> getVideoProgress(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.learningVideoProgress(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    final root = _map(response.data as Map);
    final data = root['data'];
    return data is Map ? VideoProgress.fromJson(_map(data)) : null;
  }

  Future<VideoProgress> updateVideoProgress(
    int id,
    int percentage, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.post<Object?>(
      ApiEndpoints.learningVideoProgress(id),
      data: {'watch_percentage': percentage.clamp(0, 100)},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return VideoProgress.fromJson(_dataMap(response.data));
  }

  Future<VideoProgress> completeVideo(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.post<Object?>(
      ApiEndpoints.learningVideoComplete(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return VideoProgress.fromJson(_dataMap(response.data));
  }

  static Map<String, Object?> _dataMap(Object? raw) {
    if (raw is! Map) throw const InvalidResponseException();
    final data = raw['data'];
    if (data is! Map) throw const InvalidResponseException();
    return _map(data);
  }

  static Map<String, Object?> _map(Map raw) =>
      raw.map((key, value) => MapEntry(key.toString(), value));
}
