class ResidentLeaderboardEntry {
  const ResidentLeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.score,
    required this.scoreUnit,
    required this.isCurrentUser,
    required this.isTied,
  });
  factory ResidentLeaderboardEntry.fromJson(Map<String, Object?> json) {
    final rank = json['rank'],
        name = json['display_name'],
        score = _number(json['score']);
    if (rank is! int || rank < 1 || name is! String || score == null) {
      throw const FormatException('Invalid resident ranking response.');
    }
    return ResidentLeaderboardEntry(
      rank: rank,
      displayName: name,
      score: score,
      scoreUnit: json['score_unit'] as String? ?? '',
      isCurrentUser: json['is_current_user'] == true,
      isTied: json['is_tied'] == true,
    );
  }
  final int rank;
  final String displayName;
  final num score;
  final String scoreUnit;
  final bool isCurrentUser, isTied;
  static num? _number(Object? value) => value is num
      ? value
      : value is String
      ? num.tryParse(value)
      : null;
  @override
  String toString() =>
      'ResidentLeaderboardEntry(rank: $rank, current: $isCurrentUser)';
}
