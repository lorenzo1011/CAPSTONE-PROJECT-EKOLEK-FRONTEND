import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/notifications/models/app_notification.dart';
import 'package:ekolek_app/features/notifications/models/app_notification_type.dart';
import 'package:ekolek_app/features/notifications/models/notification_action.dart';
import 'package:ekolek_app/features/notifications/models/notification_unread_count.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verified Notification Center foundation', () {
    test('uses only resident-safe verified endpoints', () {
      expect(ApiEndpoints.notifications, 'mobile/notifications/');
      expect(ApiEndpoints.notification(4), 'mobile/notifications/4/');
      expect(
        ApiEndpoints.markNotificationRead(4),
        'mobile/notifications/4/read/',
      );
      expect(
        ApiEndpoints.notificationUnreadCount,
        'mobile/notifications/unread-count/',
      );
      expect(
        ApiEndpoints.markAllNotificationsRead,
        'mobile/notifications/mark-all-read/',
      );
      expect(ApiEndpoints.deviceToken, 'mobile/device-token/');
      expect(ApiEndpoints.notifications, isNot(contains('admin')));
    });
    test('parses verified notification and read fields', () {
      final item = AppNotification.fromJson(_json());
      expect(item.type, AppNotificationType.collectionEvent);
      expect(item.isUnread, isTrue);
      expect(item.action.type, NotificationActionType.collectionEvent);
      expect(item.action.entityId, 12);
    });
    test('unknown type maps safely', () {
      final item = AppNotification.fromJson(
        _json()..['notification_type'] = 'FUTURE_TYPE',
      );
      expect(item.type, AppNotificationType.unknown);
    });
    test('unknown and arbitrary actions stay on detail', () {
      final action = NotificationAction.fromJson('https://evil.example', '99');
      expect(action.type, NotificationActionType.detail);
      expect(action.hasValidEntity, isFalse);
    });
    test('invalid action identifier cannot navigate', () {
      final action = NotificationAction.fromJson('COLLECTION_EVENT', 'secret');
      expect(action.entityId, isNull);
      expect(action.hasValidEntity, isFalse);
    });
    test('unread count preserves value and caps presentation only', () {
      const count = NotificationUnreadCount(123);
      expect(count.value, 123);
      expect(count.display, '99+');
    });
    test('notification toString excludes title body and action data', () {
      final item = AppNotification.fromJson(_json());
      expect(item.toString(), isNot(contains('Collection tomorrow')));
      expect(item.toString(), isNot(contains('Private notification body')));
      expect(item.toString(), isNot(contains('12')));
    });
    test('missing read state remains unread', () {
      final item = AppNotification.fromJson(_json()..remove('is_read'));
      expect(item.isUnread, isTrue);
    });
  });
}

Map<String, Object?> _json() => {
  'id': 4,
  'title': 'Collection tomorrow',
  'message': 'Private notification body',
  'notification_type': 'COLLECTION_EVENT',
  'is_read': false,
  'read_at': null,
  'created_at': '2026-07-22T00:00:00Z',
  'action_type': 'COLLECTION_EVENT',
  'action_id': '12',
};
