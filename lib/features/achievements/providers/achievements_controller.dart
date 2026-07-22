import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../models/achievement_badge.dart';
import '../services/achievements_service.dart';
import 'achievements_state.dart';

class AchievementsController extends ChangeNotifier {
  AchievementsController(this._service);
  final AchievementsService _service;
  AchievementsState state = const AchievementsState();
  CancelToken? _cancel;
  bool _busy = false;
  int _page = 1;

  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      phase: state.badges.isEmpty
          ? AchievementsPhase.loading
          : AchievementsPhase.refreshing,
      clearMessage: true,
    );
    notifyListeners();
    _cancel = CancelToken();
    try {
      final results = await Future.wait([
        _service.getBadges(page: 1, cancelToken: _cancel),
        _service.getSummary(cancelToken: _cancel),
      ]);
      final page = results[0] as dynamic;
      state = state.copyWith(
        phase: AchievementsPhase.loaded,
        badges: _dedupe(page.items as List<AchievementBadge>),
        summary: results[1] as dynamic,
        hasNext: page.hasNext as bool,
        isStale: false,
      );
    } on NetworkException {
      state = state.copyWith(
        phase: AchievementsPhase.offline,
        isStale: state.badges.isNotEmpty,
        message:
            'You appear to be offline. Connect to the internet and try again.',
      );
    } on AppException {
      state = state.copyWith(
        phase: AchievementsPhase.failure,
        isStale: state.badges.isNotEmpty,
        message: 'Your achievements could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(phase: AchievementsPhase.loadingMore);
    notifyListeners();
    try {
      final next = await _service.getBadges(page: ++_page);
      state = state.copyWith(
        phase: AchievementsPhase.loaded,
        badges: _dedupe([...state.badges, ...next.items]),
        hasNext: next.hasNext,
      );
    } on AppException {
      _page--;
      state = state.copyWith(
        phase: AchievementsPhase.loaded,
        message: 'More achievements could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  List<AchievementBadge> _dedupe(List<AchievementBadge> items) {
    final ids = <int>{};
    return items.where((item) => ids.add(item.id)).toList(growable: false);
  }

  void reset() {
    _cancel?.cancel();
    _page = 1;
    state = const AchievementsState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
