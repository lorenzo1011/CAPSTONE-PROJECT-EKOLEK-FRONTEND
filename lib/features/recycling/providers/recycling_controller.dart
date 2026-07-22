import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/models/auth_user.dart';
import '../services/recycling_service.dart';
import 'recycling_state.dart';

class RecyclingController extends ChangeNotifier {
  RecyclingController(this._service);
  final RecyclingService _service;
  RecyclingState state = const RecyclingState();
  CancelToken? _cancel;
  Future<void>? _active;
  int _page = 1;

  Future<void> load(AuthUser user, {bool refresh = false, bool more = false}) {
    if (_active != null) return _active!;
    if (!user.isApprovedResident || (more && !state.hasNext)) {
      return Future.value();
    }
    final future = _load(refresh: refresh, more: more);
    _active = future;
    future.whenComplete(() => _active = null);
    return future;
  }

  Future<void> _load({required bool refresh, required bool more}) async {
    if (refresh) _page = 1;
    state = RecyclingState(
      phase: more
          ? RecyclingPhase.loadingMore
          : state.collections.isEmpty
          ? RecyclingPhase.loading
          : RecyclingPhase.refreshing,
      collections: state.collections,
      materials: state.materials,
      hasNext: state.hasNext,
      refreshedAt: state.refreshedAt,
    );
    notifyListeners();
    _cancel = CancelToken();
    String? historyError;
    String? materialsError;
    var collections = state.collections;
    var materials = state.materials;
    var hasNext = state.hasNext;
    try {
      try {
        final page = await _service.history(
          page: more ? _page : 1,
          cancelToken: _cancel,
        );
        final known = more
            ? collections.map((item) => item.id).toSet()
            : <int>{};
        collections = [
          if (more) ...collections,
          ...page.items.where((item) => known.add(item.id)),
        ];
        hasNext = page.hasNext;
        _page = page.hasNext ? (more ? _page + 1 : 2) : 1;
      } on AppException {
        historyError =
            'Your recycling activity could not be loaded. Please try again.';
      }
      if (!more) {
        try {
          materials = await _service.materials(cancelToken: _cancel);
        } on AppException {
          materialsError =
              'Recyclable-material information could not be loaded.';
        }
      }
      final failed = historyError != null && collections.isEmpty;
      state = RecyclingState(
        phase: failed ? RecyclingPhase.failure : RecyclingPhase.loaded,
        collections: collections,
        materials: materials,
        hasNext: hasNext,
        message: historyError,
        materialsMessage: materialsError,
        stale: historyError != null,
        refreshedAt: failed ? state.refreshedAt : DateTime.now().toUtc(),
      );
    } on NetworkException {
      state = RecyclingState(
        phase: RecyclingPhase.offline,
        collections: collections,
        materials: materials,
        hasNext: hasNext,
        message:
            'You appear to be offline. Connect to the internet and try again.',
        stale: collections.isNotEmpty,
        refreshedAt: state.refreshedAt,
      );
    }
    notifyListeners();
  }

  void reset() {
    _cancel?.cancel();
    _page = 1;
    state = const RecyclingState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
