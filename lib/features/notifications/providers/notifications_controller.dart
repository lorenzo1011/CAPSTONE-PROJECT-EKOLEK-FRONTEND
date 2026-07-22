import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import 'notifications_state.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController(this._service);
  final NotificationService _service;
  NotificationsState state = const NotificationsState();
  CancelToken? _cancel;
  bool _busy = false;
  int _page = 1;
  final Set<int> _marking = {};
  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      phase: state.items.isEmpty
          ? NotificationsPhase.loading
          : NotificationsPhase.refreshing,
      clearMessage: true,
    );
    notifyListeners();
    _cancel = CancelToken();
    try {
      final page = await _service.getNotifications(cancelToken: _cancel);
      final count = await _service.getUnreadCount(cancelToken: _cancel);
      state = state.copyWith(
        phase: NotificationsPhase.loaded,
        items: _dedupe(page.items),
        unreadCount: count.value,
        hasNext: page.hasNext,
        isStale: false,
      );
    } on NetworkException {
      state = state.copyWith(
        phase: NotificationsPhase.offline,
        isStale: state.items.isNotEmpty,
        message:
            'You appear to be offline. Connect to the internet and try again.',
      );
    } on AppException {
      state = state.copyWith(
        phase: NotificationsPhase.failure,
        isStale: state.items.isNotEmpty,
        message: 'Your notifications could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> markRead(int id) async {
    final existing = state.items.where((item) => item.id == id).firstOrNull;
    if (existing?.isRead == true || !_marking.add(id)) return true;
    try {
      final confirmed = await _service.markRead(id);
      final count = await _service.getUnreadCount();
      state = state.copyWith(
        items: state.items
            .map((item) => item.id == id ? confirmed : item)
            .toList(growable: false),
        unreadCount: count.value,
      );
      notifyListeners();
      return true;
    } on AppException {
      state = state.copyWith(
        message: 'This notification could not be marked as read.',
      );
      notifyListeners();
      return false;
    } finally {
      _marking.remove(id);
    }
  }

  Future<void> markAllRead() async {
    if (_busy || state.unreadCount == 0) return;
    _busy = true;
    state = state.copyWith(
      phase: NotificationsPhase.updating,
      clearMessage: true,
    );
    notifyListeners();
    try {
      final count = await _service.markAllRead();
      state = state.copyWith(
        phase: NotificationsPhase.loaded,
        items: state.items
            .map((item) => item.copyWith(isRead: true))
            .toList(growable: false),
        unreadCount: count.value,
      );
    } on AppException {
      state = state.copyWith(
        phase: NotificationsPhase.loaded,
        message: 'Your notifications could not be marked as read.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(phase: NotificationsPhase.loadingMore);
    notifyListeners();
    try {
      final next = await _service.getNotifications(page: ++_page);
      state = state.copyWith(
        phase: NotificationsPhase.loaded,
        items: _dedupe([...state.items, ...next.items]),
        hasNext: next.hasNext,
      );
    } on AppException {
      _page--;
      state = state.copyWith(
        phase: NotificationsPhase.loaded,
        message: 'More notifications could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  List<AppNotification> _dedupe(List<AppNotification> items) {
    final ids = <int>{};
    return items.where((item) => ids.add(item.id)).toList(growable: false);
  }

  void reset() {
    _cancel?.cancel();
    _page = 1;
    _marking.clear();
    state = const NotificationsState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
