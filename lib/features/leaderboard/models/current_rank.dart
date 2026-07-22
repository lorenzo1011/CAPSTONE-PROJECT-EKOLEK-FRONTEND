import 'leaderboard_metric.dart';
import 'leaderboard_period.dart';

class CurrentRank {
  const CurrentRank({
    required this.rank,
    required this.score,
    required this.totalEligibleEntries,
    required this.isRanked,
    required this.metric,
    required this.scoreLabel,
    required this.scoreUnit,
    required this.period,
    required this.updatedAt,
  });
  factory CurrentRank.fromJson(Map<String, Object?> json) => CurrentRank(
    rank: json['rank'] as int?,
    score: _number(json['score']),
    totalEligibleEntries: json['total_eligible_entries'] as int? ?? 0,
    isRanked: json['is_ranked'] == true,
    metric: LeaderboardMetric.fromJson(json['metric']),
    scoreLabel: json['score_label'] as String? ?? 'Verified score',
    scoreUnit: json['score_unit'] as String? ?? '',
    period: LeaderboardPeriod.fromJson(json['period']),
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );
  final int? rank;
  final num? score;
  final int totalEligibleEntries;
  final bool isRanked;
  final LeaderboardMetric metric;
  final String scoreLabel, scoreUnit;
  final LeaderboardPeriod period;
  final DateTime? updatedAt;
  static num? _number(Object? value) => value is num
      ? value
      : value is String
      ? num.tryParse(value)
      : null;
}
