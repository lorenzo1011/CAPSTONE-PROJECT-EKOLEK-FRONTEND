import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../models/eco_challenge.dart';
import '../services/challenges_service.dart';
import 'challenges_state.dart';

class ChallengesController extends ChangeNotifier {
  ChallengesController(this._service);
  final ChallengesService _service;
  ChallengesState state = const ChallengesState();
  CancelToken? _cancel;
  bool _busy = false;
  int _page = 1;

  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      phase: state.items.isEmpty
          ? ChallengesPhase.loading
          : ChallengesPhase.refreshing,
      clearMessage: true,
    );
    notifyListeners();
    _cancel = CancelToken();
    try {
      final catalog = await _service.getChallenges(
        page: _page,
        cancelToken: _cancel,
      );
      var history = state.history;
      try {
        history = (await _service.getHistory(
          pageSize: 5,
          cancelToken: _cancel,
        )).items;
      } on AppException {
        state = state.copyWith(
          message: 'Your challenge progress could not be loaded.',
        );
      }
      state = state.copyWith(
        phase: ChallengesPhase.loaded,
        items: _dedupe(catalog.items),
        history: history,
        hasNext: catalog.hasNext,
        isStale: false,
      );
    } on NetworkException {
      state = state.copyWith(
        phase: ChallengesPhase.offline,
        isStale: state.items.isNotEmpty,
        message:
            'You appear to be offline. Connect to the internet and try again.',
      );
    } on AppException {
      state = state.copyWith(
        phase: ChallengesPhase.failure,
        isStale: state.items.isNotEmpty,
        message: 'Eco challenges could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(phase: ChallengesPhase.loadingMore);
    notifyListeners();
    try {
      final next = await _service.getChallenges(page: ++_page);
      state = state.copyWith(
        phase: ChallengesPhase.loaded,
        items: _dedupe([...state.items, ...next.items]),
        hasNext: next.hasNext,
      );
    } on AppException {
      _page--;
      state = state.copyWith(
        phase: ChallengesPhase.loaded,
        message: 'More eco challenges could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  List<EcoChallenge> _dedupe(List<EcoChallenge> values) {
    final ids = <int>{};
    return values.where((value) => ids.add(value.id)).toList(growable: false);
  }

  void reset() {
    _cancel?.cancel();
    _page = 1;
    state = const ChallengesState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
