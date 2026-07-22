class NotificationUnreadCount {
  const NotificationUnreadCount(this.value);
  factory NotificationUnreadCount.fromJson(Map<String, Object?> json) =>
      NotificationUnreadCount(
        (json['unread_count'] as int? ?? 0).clamp(0, 1 << 31),
      );
  final int value;
  String get display => value > 99 ? '99+' : '$value';
}
