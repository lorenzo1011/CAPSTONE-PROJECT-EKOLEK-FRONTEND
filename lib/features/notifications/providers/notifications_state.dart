import '../models/app_notification.dart';

enum NotificationsPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  updating,
  offline,
  failure,
}

class NotificationsState {
  const NotificationsState({
    this.phase = NotificationsPhase.initial,
    this.items = const [],
    this.unreadCount = 0,
    this.hasNext = false,
    this.isStale = false,
    this.message,
  });
  final NotificationsPhase phase;
  final List<AppNotification> items;
  final int unreadCount;
  final bool hasNext, isStale;
  final String? message;
  NotificationsState copyWith({
    NotificationsPhase? phase,
    List<AppNotification>? items,
    int? unreadCount,
    bool? hasNext,
    bool? isStale,
    String? message,
    bool clearMessage = false,
  }) => NotificationsState(
    phase: phase ?? this.phase,
    items: items ?? this.items,
    unreadCount: unreadCount ?? this.unreadCount,
    hasNext: hasNext ?? this.hasNext,
    isStale: isStale ?? this.isStale,
    message: clearMessage ? null : message ?? this.message,
  );
}
