import 'game_availability.dart';
import 'game_type.dart';

class EcoGame {
  const EcoGame({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsPerPlay,
    required this.dailyPointsLimit,
    required this.pointsEarnedToday,
    required this.remainingPointsToday,
    required this.playCountToday,
    required this.isDailyLimitEnabled,
    required this.dailyLimitReached,
    required this.playAllowedAfterLimit,
    this.highScore,
    this.latestScore,
    this.availability = GameAvailability.available,
  });
  factory EcoGame.fromJson(Map<String, Object?> json) => EcoGame(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    type: EcoGameType.fromBackend(json['game_type']),
    pointsPerPlay: json['points_per_play'] as int,
    dailyPointsLimit: json['daily_points_limit'] as int,
    pointsEarnedToday: json['points_earned_today'] as int,
    remainingPointsToday: json['remaining_points_today'] as int,
    playCountToday: json['play_count_today'] as int,
    highScore: json['high_score'] as int?,
    latestScore: json['latest_score'] as int?,
    isDailyLimitEnabled: json['is_daily_limit_enabled'] == true,
    dailyLimitReached: json['daily_limit_reached'] == true,
    playAllowedAfterLimit: json['play_allowed_after_limit'] == true,
  );
  final int id;
  final String title;
  final String description;
  final EcoGameType type;
  final int pointsPerPlay;
  final int dailyPointsLimit;
  final int pointsEarnedToday;
  final int remainingPointsToday;
  final int playCountToday;
  final int? highScore;
  final int? latestScore;
  final bool isDailyLimitEnabled;
  final bool dailyLimitReached;
  final bool playAllowedAfterLimit;
  final GameAvailability availability;
  bool get hasHighScore => highScore != null;
  bool get hasReachedDailyPointLimit => dailyLimitReached;
  bool get canStillPlayWithoutPoints =>
      dailyLimitReached && playAllowedAfterLimit;
}
