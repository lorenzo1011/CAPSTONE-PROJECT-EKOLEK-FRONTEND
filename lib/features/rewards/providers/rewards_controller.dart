import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../models/reward_item.dart';
import '../services/rewards_service.dart';
import 'rewards_state.dart';

class RewardsController extends ChangeNotifier {
  RewardsController(this._service);
  final RewardsService _service;
  RewardsState state = const RewardsState();
  CancelToken? _cancel;
  bool _busy = false;
  int _page = 1;
  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      phase: state.items.isEmpty
          ? RewardsPhase.loading
          : RewardsPhase.refreshing,
      clearMessage: true,
    );
    notifyListeners();
    _cancel?.cancel();
    _cancel = CancelToken();
    try {
      final r = await Future.wait([
        _service.getRewards(
          page: 1,
          search: state.search,
          category: state.selectedCategory,
          cancelToken: _cancel,
        ),
        _service.getCategories(cancelToken: _cancel),
      ]);
      final page = r[0] as dynamic;
      state = state.copyWith(
        phase: RewardsPhase.loaded,
        items: _dedupe(page.items as List<RewardItem>),
        categories: r[1] as dynamic,
        hasNext: page.hasNext as bool,
        stale: false,
      );
    } on NetworkException {
      state = state.copyWith(
        phase: RewardsPhase.offline,
        stale: state.items.isNotEmpty,
        message:
            'Showing the last reward information loaded on this device. Stock and eligibility may have changed.',
      );
    } on AppException {
      state = state.copyWith(
        phase: RewardsPhase.failure,
        stale: state.items.isNotEmpty,
        message: 'Rewards could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String? value) async {
    state = state.copyWith(
      selectedCategory: value,
      clearCategory: value == null,
    );
    await load(refresh: true);
  }

  Future<void> search(String value) async {
    state = state.copyWith(search: value.trim());
    await load(refresh: true);
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(phase: RewardsPhase.loadingMore);
    notifyListeners();
    try {
      final p = await _service.getRewards(
        page: ++_page,
        search: state.search,
        category: state.selectedCategory,
      );
      state = state.copyWith(
        phase: RewardsPhase.loaded,
        items: _dedupe([...state.items, ...p.items]),
        hasNext: p.hasNext,
      );
    } on AppException {
      _page--;
      state = state.copyWith(
        phase: RewardsPhase.loaded,
        message: 'More rewards could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  List<RewardItem> _dedupe(List<RewardItem> x) {
    final ids = <int>{};
    return x.where((e) => ids.add(e.id)).toList();
  }

  void reset() {
    _cancel?.cancel();
    _page = 1;
    state = const RewardsState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
