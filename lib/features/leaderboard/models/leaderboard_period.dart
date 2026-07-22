enum LeaderboardPeriod {
  monthly('MONTHLY', 'This month'),
  allTime('ALL_TIME', 'All time'),
  unknown('UNKNOWN', 'Period unavailable');

  const LeaderboardPeriod(this.value, this.label);
  final String value, label;
  static LeaderboardPeriod fromJson(Object? value) =>
      LeaderboardPeriod.values.firstWhere(
        (item) => item.value == value,
        orElse: () => LeaderboardPeriod.unknown,
      );
}
