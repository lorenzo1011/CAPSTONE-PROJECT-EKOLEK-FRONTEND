class BarangayLeaderboardEntry {
  const BarangayLeaderboardEntry({
    required this.rank,
    required this.barangayName,
    required this.score,
    required this.scoreUnit,
    required this.eligibleResidentCount,
    required this.isCurrentBarangay,
    required this.isTied,
  });
  factory BarangayLeaderboardEntry.fromJson(Map<String, Object?> json) {
    final rank = json['rank'],
        name = json['barangay_name'],
        score = _number(json['score']);
    if (rank is! int || rank < 1 || name is! String || score == null) {
      throw const FormatException('Invalid barangay ranking response.');
    }
    return BarangayLeaderboardEntry(
      rank: rank,
      barangayName: name,
      score: score,
      scoreUnit: json['score_unit'] as String? ?? '',
      eligibleResidentCount: json['eligible_resident_count'] as int? ?? 0,
      isCurrentBarangay: json['is_current_barangay'] == true,
      isTied: json['is_tied'] == true,
    );
  }
  final int rank;
  final String barangayName;
  final num score;
  final String scoreUnit;
  final int eligibleResidentCount;
  final bool isCurrentBarangay, isTied;
  static num? _number(Object? value) => value is num
      ? value
      : value is String
      ? num.tryParse(value)
      : null;
}
