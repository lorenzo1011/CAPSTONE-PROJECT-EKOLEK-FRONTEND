import 'learning_quiz_summary.dart';
import 'video_progress.dart';

enum LearningVideoSource { youtube, unsupported }

class LearningVideo {
  const LearningVideo({
    required this.id,
    required this.title,
    required this.category,
    required this.pointsReward,
    required this.requiredWatchPercentage,
    this.description = '',
    this.thumbnailUrl,
    this.source = LearningVideoSource.unsupported,
    this.providerVideoId,
    this.progress,
    this.quiz,
  });

  factory LearningVideo.fromJson(Map<String, Object?> json) {
    final rawProgress = json['progress'];
    final rawQuiz = json['quiz'];
    return LearningVideo(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail'] as String?,
      category: json['category'] as String? ?? '',
      pointsReward: json['points_reward'] as int?,
      requiredWatchPercentage: json['required_watch_percentage'] as int?,
      source: json['video_source'] == 'youtube'
          ? LearningVideoSource.youtube
          : LearningVideoSource.unsupported,
      providerVideoId: json['provider_video_id'] as String?,
      progress: rawProgress is Map
          ? VideoProgress.fromJson(_map(rawProgress))
          : null,
      quiz: rawQuiz is Map ? LearningQuizSummary.fromJson(_map(rawQuiz)) : null,
    );
  }

  final int id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String category;
  final int? pointsReward;
  final int? requiredWatchPercentage;
  final LearningVideoSource source;
  final String? providerVideoId;
  final VideoProgress? progress;
  final LearningQuizSummary? quiz;

  LearningVideo copyWith({
    VideoProgress? progress,
    LearningQuizSummary? quiz,
  }) => LearningVideo(
    id: id,
    title: title,
    description: description,
    thumbnailUrl: thumbnailUrl,
    category: category,
    pointsReward: pointsReward,
    requiredWatchPercentage: requiredWatchPercentage,
    source: source,
    providerVideoId: providerVideoId,
    progress: progress ?? this.progress,
    quiz: quiz ?? this.quiz,
  );

  static Map<String, Object?> _map(Map value) =>
      value.map((key, value) => MapEntry(key.toString(), value));
}
