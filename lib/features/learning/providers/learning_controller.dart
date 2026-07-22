import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../models/video_progress.dart';
import '../services/learning_service.dart';
import 'learning_state.dart';

class LearningController extends ChangeNotifier {
  LearningController(this._service);
  final LearningService _service;
  LearningState state = const LearningState();
  CancelToken? _token;
  int _page = 1;
  bool _busy = false;

  Future<void> load({bool refresh = false}) async {
    if (_busy) return;
    _busy = true;
    if (refresh) _page = 1;
    state = state.copyWith(
      status: refresh && state.videos.isNotEmpty
          ? LearningStatus.refreshing
          : LearningStatus.loading,
      clearMessage: true,
    );
    notifyListeners();
    _token = CancelToken();
    try {
      final result = await _service.getLearningVideos(
        page: _page,
        category: state.selectedCategory,
        search: state.searchQuery,
        cancelToken: _token,
      );
      state = state.copyWith(
        status: LearningStatus.loaded,
        videos: _dedupe(result.items),
        hasNext: result.hasNext,
        isStale: false,
        clearMessage: true,
      );
    } on NoInternetException {
      state = state.copyWith(
        status: LearningStatus.offline,
        isStale: state.videos.isNotEmpty,
        message:
            'You appear to be offline. Connect to the internet and try again.',
      );
    } on AppException {
      state = state.copyWith(
        status: LearningStatus.failure,
        isStale: state.videos.isNotEmpty,
        message: 'Learning content could not be loaded. Please try again.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasNext) return;
    _busy = true;
    state = state.copyWith(status: LearningStatus.loadingMore);
    notifyListeners();
    try {
      final result = await _service.getLearningVideos(
        page: ++_page,
        category: state.selectedCategory,
        search: state.searchQuery,
      );
      state = state.copyWith(
        status: LearningStatus.loaded,
        videos: _dedupe([...state.videos, ...result.items]),
        hasNext: result.hasNext,
      );
    } on AppException {
      _page--;
      state = state.copyWith(
        status: LearningStatus.loaded,
        message: 'More learning content could not be loaded.',
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> setCategory(String? value) async {
    state = state.copyWith(
      selectedCategory: value,
      clearCategory: value == null,
    );
    await load(refresh: true);
  }

  void updateProgress(int id, VideoProgress progress) {
    state = state.copyWith(
      videos: [
        for (final video in state.videos)
          video.id == id ? video.copyWith(progress: progress) : video,
      ],
    );
    notifyListeners();
  }

  List<T> _dedupe<T>(List<T> items) {
    if (T != dynamic) {
      final seen = <int>{};
      return items
          .where((item) => seen.add((item as dynamic).id as int))
          .toList();
    }
    return items;
  }

  void reset() {
    _token?.cancel();
    _page = 1;
    state = const LearningState();
    notifyListeners();
  }

  @override
  void dispose() {
    _token?.cancel();
    super.dispose();
  }
}
