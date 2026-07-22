import 'achievement_badge.dart';

class AchievementSummary {
  const AchievementSummary({
    required this.totalVisible,
    required this.totalUnlocked,
    required this.totalLocked,
    required this.completionPercentage,
    required this.badgesByType,
    this.latestUnlocked,
  });
  factory AchievementSummary.fromJson(Map<String, Object?> json) =>
      AchievementSummary(
        totalVisible: json['total_visible_badges'] as int? ?? 0,
        totalUnlocked: json['total_unlocked_badges'] as int? ?? 0,
        totalLocked: json['total_locked_badges'] as int? ?? 0,
        completionPercentage:
            (json['completion_percentage'] as num?)?.toDouble() ?? 0,
        badgesByType:
            (json['badges_by_type'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value as int? ?? 0),
            ) ??
            const {},
        latestUnlocked: json['latest_unlocked_badge'] is Map
            ? AchievementBadge.fromJson(
                _map(json['latest_unlocked_badge'] as Map),
              )
            : null,
      );
  final int totalVisible;
  final int totalUnlocked;
  final int totalLocked;
  final double completionPercentage;
  final Map<String, int> badgesByType;
  final AchievementBadge? latestUnlocked;
  static Map<String, Object?> _map(Map value) =>
      value.map((key, item) => MapEntry(key.toString(), item));
}
