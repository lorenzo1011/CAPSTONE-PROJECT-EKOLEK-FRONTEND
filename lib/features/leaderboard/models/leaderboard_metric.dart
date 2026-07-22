enum LeaderboardMetric {
  totalEarnedPoints('TOTAL_EARNED_POINTS'),
  recycledWeight('RECYCLED_WEIGHT'),
  challengeScore('CHALLENGE_SCORE'),
  monthlyEarnedPoints('MONTHLY_EARNED_POINTS'),
  unknown('UNKNOWN');

  const LeaderboardMetric(this.value);
  final String value;
  static LeaderboardMetric fromJson(Object? value) =>
      LeaderboardMetric.values.firstWhere(
        (item) => item.value == value,
        orElse: () => LeaderboardMetric.unknown,
      );
}
