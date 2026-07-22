import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/app_notification.dart';
import '../models/notification_unread_count.dart';

class NotificationService {
  NotificationService(this._client);
  final ApiClient _client;
  Future<PaginatedResponse<AppNotification>> getNotifications({
    int page = 1,
    String? type,
    CancelToken? cancelToken,
  }) async {
    final query = <String, Object?>{'page': page, 'page_size': 20};
    if (type != null) query['type'] = type;
    final response = await _client.get<Object?>(
      ApiEndpoints.notifications,
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
          .map((item) => AppNotification.fromJson(_map(item)))
          .toList(growable: false),
      hasNext: data['next'] != null,
    );
  }

  Future<AppNotification> getNotification(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.notification(id),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return AppNotification.fromJson(_data(response.data));
  }

  Future<NotificationUnreadCount> getUnreadCount({
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.notificationUnreadCount,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return NotificationUnreadCount.fromJson(_data(response.data));
  }

  Future<AppNotification> markRead(int id) async {
    final response = await _client.post<Object?>(
      ApiEndpoints.markNotificationRead(id),
      options: AuthRequestOptions.authenticated(),
    );
    return AppNotification.fromJson(_data(response.data));
  }

  Future<NotificationUnreadCount> markAllRead() async {
    final response = await _client.post<Object?>(
      ApiEndpoints.markAllNotificationsRead,
      options: AuthRequestOptions.authenticated(),
    );
    return NotificationUnreadCount.fromJson(_data(response.data));
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
