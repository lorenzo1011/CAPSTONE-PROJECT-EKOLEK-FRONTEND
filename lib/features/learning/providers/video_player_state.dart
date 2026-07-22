import '../models/learning_video.dart';
import '../models/video_progress.dart';

enum LearningPlaybackStatus {
  initial,
  loading,
  ready,
  playing,
  paused,
  buffering,
  updatingProgress,
  completing,
  completed,
  failure,
}

class LearningPlaybackState {
  const LearningPlaybackState({
    this.status = LearningPlaybackStatus.initial,
    this.video,
    this.progress,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.message,
  });
  final LearningPlaybackStatus status;
  final LearningVideo? video;
  final VideoProgress? progress;
  final Duration position;
  final Duration duration;
  final String? message;
  LearningPlaybackState copyWith({
    LearningPlaybackStatus? status,
    LearningVideo? video,
    VideoProgress? progress,
    Duration? position,
    Duration? duration,
    String? message,
    bool clearMessage = false,
  }) => LearningPlaybackState(
    status: status ?? this.status,
    video: video ?? this.video,
    progress: progress ?? this.progress,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    message: clearMessage ? null : message ?? this.message,
  );
}
