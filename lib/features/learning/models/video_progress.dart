class VideoProgress {
  const VideoProgress({
    required this.watchPercentage,
    required this.isCompleted,
    required this.pointsAwarded,
    this.completedAt,
    this.updatedAt,
    this.pointsAwardedNow = false,
    this.pointsAwardedAmount = 0,
  });

  factory VideoProgress.fromJson(Map<String, Object?> json) {
    final raw = json['watch_percentage'];
    final percentage = raw is num ? raw.toInt().clamp(0, 100) : 0;
    return VideoProgress(
      watchPercentage: percentage,
      isCompleted: json['is_completed'] == true,
      pointsAwarded: json['points_awarded'] == true,
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      pointsAwardedNow: json['points_awarded_now'] == true,
      pointsAwardedAmount: json['points_awarded_amount'] as int? ?? 0,
    );
  }

  final int watchPercentage;
  final bool isCompleted;
  final bool pointsAwarded;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  final bool pointsAwardedNow;
  final int pointsAwardedAmount;
  bool get canResume => !isCompleted && watchPercentage > 0;
}
