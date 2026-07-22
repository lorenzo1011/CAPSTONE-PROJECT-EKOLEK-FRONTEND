import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/learning_video.dart';
import '../services/learning_service.dart';
import 'video_player_state.dart';

class LearningVideoController extends ChangeNotifier
    with WidgetsBindingObserver {
  LearningVideoController(this._service, this.videoId);
  static const progressInterval = Duration(seconds: 12);
  final LearningService _service;
  final int videoId;
  LearningPlaybackState state = const LearningPlaybackState();
  YoutubePlayerController? player;
  CancelToken? _token;
  Timer? _timer;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  StreamSubscription<YoutubeVideoState>? _videoSubscription;
  int _lastSubmitted = 0;
  bool _sending = false;
  bool _completionSent = false;

  Future<void> initialize() async {
    if (state.status != LearningPlaybackStatus.initial &&
        state.status != LearningPlaybackStatus.failure) {
      return;
    }
    state = const LearningPlaybackState(status: LearningPlaybackStatus.loading);
    notifyListeners();
    WidgetsBinding.instance.addObserver(this);
    _token = CancelToken();
    try {
      final video = await _service.getLearningVideoDetail(
        videoId,
        cancelToken: _token,
      );
      final progress =
          video.progress ??
          await _service.getVideoProgress(videoId, cancelToken: _token);
      if (video.source != LearningVideoSource.youtube ||
          video.providerVideoId?.isNotEmpty != true) {
        state = LearningPlaybackState(
          status: LearningPlaybackStatus.failure,
          video: video,
          progress: progress,
          message: 'This learning video is currently unavailable.',
        );
        notifyListeners();
        return;
      }
      _lastSubmitted = progress?.watchPercentage ?? 0;
      player = YoutubePlayerController.fromVideoId(
        videoId: video.providerVideoId!,
        autoPlay: false,
        params: const YoutubePlayerParams(
          enableCaption: true,
          showControls: true,
          showFullscreenButton: true,
        ),
      );
      _playerSubscription = player!.stream.listen(_onPlayerChange);
      _videoSubscription = player!.videoStateStream.listen((value) {
        state = state.copyWith(
          position: value.position,
          duration: player!.metadata.duration,
        );
        notifyListeners();
      });
      _timer = Timer.periodic(progressInterval, (_) => submitProgress());
      state = LearningPlaybackState(
        status: progress?.isCompleted == true
            ? LearningPlaybackStatus.completed
            : LearningPlaybackStatus.ready,
        video: video,
        progress: progress,
      );
      notifyListeners();
    } on AppException {
      state = const LearningPlaybackState(
        status: LearningPlaybackStatus.failure,
        message: 'This learning video is currently unavailable.',
      );
      notifyListeners();
    }
  }

  void _onPlayerChange(YoutubePlayerValue value) {
    final status = value.playerState == PlayerState.playing
        ? LearningPlaybackStatus.playing
        : value.playerState == PlayerState.buffering
        ? LearningPlaybackStatus.buffering
        : LearningPlaybackStatus.paused;
    state = state.copyWith(status: status, duration: player?.metadata.duration);
    notifyListeners();
  }

  Future<void> pause() async {
    await player?.pauseVideo();
    await submitProgress(force: true);
  }

  Future<void> submitProgress({bool force = false}) async {
    if (_sending || state.progress?.isCompleted == true) return;
    final duration = state.duration.inMilliseconds;
    if (duration <= 0) return;
    final percentage = ((state.position.inMilliseconds / duration) * 100)
        .floor()
        .clamp(0, 100);
    if (percentage <= _lastSubmitted ||
        (!force && percentage - _lastSubmitted < 1)) {
      return;
    }
    _sending = true;
    try {
      final progress = await _service.updateVideoProgress(videoId, percentage);
      _lastSubmitted = progress.watchPercentage;
      state = state.copyWith(progress: progress);
      final threshold = state.video?.requiredWatchPercentage;
      if (!_completionSent &&
          threshold != null &&
          progress.watchPercentage >= threshold) {
        await complete();
      }
    } on AppException {
      state = state.copyWith(
        message: 'Your video progress could not be updated.',
      );
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> complete() async {
    if (_completionSent || state.progress?.isCompleted == true) return;
    _completionSent = true;
    state = state.copyWith(
      status: LearningPlaybackStatus.completing,
      clearMessage: true,
    );
    notifyListeners();
    try {
      final progress = await _service.completeVideo(videoId);
      state = state.copyWith(
        status: LearningPlaybackStatus.completed,
        progress: progress,
      );
    } on AppException {
      _completionSent = false;
      state = state.copyWith(
        status: LearningPlaybackStatus.paused,
        message:
            'E-KOLEK could not confirm this learning activity. Please try again.',
      );
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _token?.cancel();
    _playerSubscription?.cancel();
    _videoSubscription?.cancel();
    player?.pauseVideo();
    player?.close();
    super.dispose();
  }
}
