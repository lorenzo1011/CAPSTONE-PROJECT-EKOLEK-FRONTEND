class LearningQuizSummary {
  const LearningQuizSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.passingScore,
    required this.pointsReward,
    required this.maxAttempts,
    required this.questionCount,
    required this.attemptCount,
    required this.isPassed,
    required this.isUnlocked,
  });

  factory LearningQuizSummary.fromJson(Map<String, Object?> json) =>
      LearningQuizSummary(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        passingScore: json['passing_score'] as int?,
        pointsReward: json['points_reward'] as int?,
        maxAttempts: json['max_attempts'] as int?,
        questionCount: json['question_count'] as int?,
        attemptCount: json['attempt_count'] as int?,
        isPassed: json['is_passed'] == true,
        isUnlocked: json['is_unlocked'] == true,
      );

  final int id;
  final String title;
  final String description;
  final int? passingScore;
  final int? pointsReward;
  final int? maxAttempts;
  final int? questionCount;
  final int? attemptCount;
  final bool isPassed;
  final bool isUnlocked;
}
