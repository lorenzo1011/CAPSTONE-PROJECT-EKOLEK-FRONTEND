import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../models/leaderboard_scope.dart';
import '../services/leaderboard_service.dart';
import 'leaderboard_state.dart';

class LeaderboardController extends ChangeNotifier {
  LeaderboardController(this._service);
  final LeaderboardService _service;
  LeaderboardState state = const LeaderboardState();
  CancelToken? _cancel;
  bool _busy = false;
  int _page = 1;
  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      phase: state.hasData
          ? LeaderboardPhase.refreshing
          : LeaderboardPhase.loading,
      clearMessage: true,
    );
    notifyListeners();
    _cancel = CancelToken();
    try {
      if (state.scope == LeaderboardScope.barangayResidents) {
        final page = await _service.getResidents(cancelToken: _cancel);
        final rank = await _service.getCurrentResidentRank(
          cancelToken: _cancel,
        );
        state = state.copyWith(residentPage: page, residentRank: rank);
      } else {
        final page = await _service.getBarangays(cancelToken: _cancel);
        final rank = await _service.getCurrentBarangayRank(
          cancelToken: _cancel,
        );
        state = state.copyWith(barangayPage: page, barangayRank: rank);
      }
      state = state.copyWith(phase: LeaderboardPhase.loaded, isStale: false);
    } on NetworkException {
      state = state.copyWith(
        phase: LeaderboardPhase.offline,
        isStale: state.hasData,
        message:
            'You appear to be offline. Connect to the internet and try again.',
      );
    } on AppException {
      state = state.copyWith(
        phase: LeaderboardPhase.failure,
        isStale: state.hasData,
        message:
            'Leaderboard information could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> selectScope(LeaderboardScope scope) async {
    if (scope == LeaderboardScope.unknown || scope == state.scope) return;
    state = state.copyWith(scope: scope);
    _page = 1;
    notifyListeners();
    await load();
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(phase: LeaderboardPhase.loadingMore);
    notifyListeners();
    try {
      if (state.scope == LeaderboardScope.barangayResidents) {
        final next = await _service.getResidents(page: ++_page);
        final old = state.residentPage!;
        final keys = <String>{};
        final items = [...old.items, ...next.items]
            .where((item) => keys.add('${item.rank}:${item.displayName}'))
            .toList();
        state = state.copyWith(residentPage: next.copyWith(items: items));
      } else {
        final next = await _service.getBarangays(page: ++_page);
        final old = state.barangayPage!;
        final names = <String>{};
        final items = [
          ...old.items,
          ...next.items,
        ].where((item) => names.add(item.barangayName)).toList();
        state = state.copyWith(barangayPage: next.copyWith(items: items));
      }
      state = state.copyWith(phase: LeaderboardPhase.loaded);
    } on AppException {
      _page--;
      state = state.copyWith(
        phase: LeaderboardPhase.loaded,
        message: 'More rankings could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void reset() {
    _cancel?.cancel();
    _page = 1;
    state = const LeaderboardState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
