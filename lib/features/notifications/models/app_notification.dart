import 'app_notification_type.dart';
import 'notification_action.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.action,
    this.readAt,
  });
  factory AppNotification.fromJson(Map<String, Object?> json) {
    final id = json['id'], title = json['title'], message = json['message'];
    if (id is! int || title is! String || message is! String) {
      throw const FormatException('Invalid notification response.');
    }
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: AppNotificationType.fromJson(json['notification_type']),
      isRead: json['is_read'] == true,
      readAt: DateTime.tryParse(json['read_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      action: NotificationAction.fromJson(
        json['action_type'],
        json['action_id'],
      ),
    );
  }
  final int id;
  final String title, message;
  final AppNotificationType type;
  final bool isRead;
  final DateTime? readAt, createdAt;
  final NotificationAction action;
  bool get isUnread => !isRead;
  AppNotification copyWith({bool? isRead, DateTime? readAt}) => AppNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    isRead: isRead ?? this.isRead,
    readAt: readAt ?? this.readAt,
    createdAt: createdAt,
    action: action,
  );
  @override
  String toString() =>
      'AppNotification(id: $id, type: ${type.name}, read: $isRead)';
}
