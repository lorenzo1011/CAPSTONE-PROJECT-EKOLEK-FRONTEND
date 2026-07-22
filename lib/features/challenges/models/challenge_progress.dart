class ChallengeProgress {
  const ChallengeProgress({
    required this.id,
    required this.currentValue,
    required this.percentage,
    required this.isCompleted,
    required this.pointsAwarded,
    this.awardedPoints,
    this.completedAt,
    this.updatedAt,
  });

  factory ChallengeProgress.fromJson(Map<String, Object?> json) =>
      ChallengeProgress(
        id: json['id'] as int? ?? 0,
        currentValue: json['current_value'] as int? ?? 0,
        percentage: double.tryParse('${json['progress_percentage']}') ?? 0,
        isCompleted: json['is_completed'] == true,
        pointsAwarded: json['points_awarded'] == true,
        awardedPoints: json['awarded_points'] as int?,
        completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      );

  final int id;
  final int currentValue;
  final double percentage;
  final bool isCompleted;
  final bool pointsAwarded;
  final int? awardedPoints;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  double get displayPercentage => percentage.clamp(0, 100);
}
