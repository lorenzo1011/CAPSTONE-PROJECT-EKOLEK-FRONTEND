import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../models/redemption_history_filter.dart';
import '../models/resident_redemption.dart';
import '../services/redemption_service.dart';
import 'redemption_history_state.dart';

class RedemptionHistoryController extends ChangeNotifier {
  RedemptionHistoryController(this._service);
  final RedemptionService _service;
  RedemptionHistoryState state = const RedemptionHistoryState();
  bool _busy = false;
  int _page = 1;
  CancelToken? _cancel;
  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      phase: state.items.isEmpty
          ? RedemptionHistoryPhase.loading
          : RedemptionHistoryPhase.refreshing,
      clearMessage: true,
    );
    notifyListeners();
    _cancel?.cancel();
    _cancel = CancelToken();
    try {
      final page = await _service.history(
        page: 1,
        status: state.filter.query,
        cancelToken: _cancel,
      );
      state = state.copyWith(
        phase: RedemptionHistoryPhase.loaded,
        items: _dedupe(page.items),
        hasNext: page.hasNext,
        stale: false,
      );
    } on NetworkException {
      state = state.copyWith(
        phase: RedemptionHistoryPhase.offline,
        stale: state.items.isNotEmpty,
        message:
            'Connect to the internet to submit or update a redemption request.',
      );
    } on AppException {
      state = state.copyWith(
        phase: RedemptionHistoryPhase.failure,
        stale: state.items.isNotEmpty,
        message: 'Your redemption history could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> select(RedemptionHistoryFilter value) async {
    state = state.copyWith(filter: value);
    await load(refresh: true);
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(phase: RedemptionHistoryPhase.loadingMore);
    notifyListeners();
    try {
      final p = await _service.history(
        page: ++_page,
        status: state.filter.query,
      );
      state = state.copyWith(
        phase: RedemptionHistoryPhase.loaded,
        items: _dedupe([...state.items, ...p.items]),
        hasNext: p.hasNext,
      );
    } on AppException {
      _page--;
      state = state.copyWith(
        phase: RedemptionHistoryPhase.loaded,
        message: 'More redemption requests could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  List<ResidentRedemption> _dedupe(List<ResidentRedemption> x) {
    final ids = <int>{};
    return x.where((e) => ids.add(e.id)).toList();
  }

  void reset() {
    _cancel?.cancel();
    _page = 1;
    state = const RedemptionHistoryState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
