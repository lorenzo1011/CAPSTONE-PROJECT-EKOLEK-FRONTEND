import 'leaderboard_metric.dart';
import 'leaderboard_period.dart';
import 'leaderboard_scope.dart';

class LeaderboardPage<T> {
  const LeaderboardPage({
    required this.items,
    required this.count,
    required this.hasNext,
    required this.scope,
    required this.scopeLabel,
    required this.metric,
    required this.scoreLabel,
    required this.scoreUnit,
    required this.period,
    required this.enabled,
    required this.updatedAt,
  });
  final List<T> items;
  final int count;
  final bool hasNext;
  final LeaderboardScope scope;
  final String scopeLabel;
  final LeaderboardMetric metric;
  final String scoreLabel, scoreUnit;
  final LeaderboardPeriod period;
  final bool enabled;
  final DateTime? updatedAt;
  LeaderboardPage<T> copyWith({List<T>? items}) => LeaderboardPage(
    items: items ?? this.items,
    count: count,
    hasNext: hasNext,
    scope: scope,
    scopeLabel: scopeLabel,
    metric: metric,
    scoreLabel: scoreLabel,
    scoreUnit: scoreUnit,
    period: period,
    enabled: enabled,
    updatedAt: updatedAt,
  );
}
