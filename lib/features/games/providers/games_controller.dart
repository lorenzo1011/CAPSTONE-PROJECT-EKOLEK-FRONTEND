import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../models/eco_game.dart';
import '../services/games_service.dart';
import 'games_state.dart';

class GamesController extends ChangeNotifier {
  GamesController(this._service);
  final GamesService _service;
  GamesState state = const GamesState();
  CancelToken? _token;
  int _page = 1;
  bool _busy = false;
  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      phase: refresh && state.games.isNotEmpty
          ? GamesPhase.refreshing
          : GamesPhase.loading,
      clearMessages: true,
    );
    notifyListeners();
    _token = CancelToken();
    try {
      final catalog = await _service.getGames(page: _page, cancelToken: _token);
      final games = _dedupe(catalog.items);
      state = state.copyWith(
        phase: GamesPhase.loaded,
        games: games,
        hasNext: catalog.hasNext,
        isStale: false,
        clearMessages: true,
      );
      notifyListeners();
      try {
        final daily = await _service.getDailyProgress(cancelToken: _token);
        state = state.copyWith(dailyProgress: daily);
      } on AppException {
        state = state.copyWith(
          dailyMessage: 'Daily game progress could not be refreshed.',
        );
      }
      try {
        final attempts = await _service.getRecentAttempts(cancelToken: _token);
        state = state.copyWith(recentAttempts: attempts.items);
      } on AppException {
        state = state.copyWith(
          attemptsMessage: 'Recent game activity could not be loaded.',
        );
      }
    } on NoInternetException {
      state = state.copyWith(
        phase: GamesPhase.offline,
        isStale: state.games.isNotEmpty,
        message:
            'You appear to be offline. Connect to the internet and try again.',
      );
    } on AppException {
      state = state.copyWith(
        phase: GamesPhase.failure,
        isStale: state.games.isNotEmpty,
        message: 'Games could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(phase: GamesPhase.loadingMore);
    notifyListeners();
    try {
      final result = await _service.getGames(page: ++_page);
      state = state.copyWith(
        phase: GamesPhase.loaded,
        games: _dedupe([...state.games, ...result.items]),
        hasNext: result.hasNext,
      );
    } on AppException {
      _page--;
      state = state.copyWith(
        phase: GamesPhase.loaded,
        message: 'More games could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  List<EcoGame> _dedupe(List<EcoGame> games) {
    final seen = <int>{};
    return games.where((game) => seen.add(game.id)).toList(growable: false);
  }

  void reset() {
    _token?.cancel();
    _page = 1;
    state = const GamesState();
    notifyListeners();
  }

  @override
  void dispose() {
    _token?.cancel();
    super.dispose();
  }
}
