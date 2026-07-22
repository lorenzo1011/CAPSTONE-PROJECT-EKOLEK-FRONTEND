class QuizResult {
  const QuizResult({
    required this.attemptId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.isPassed,
    required this.pointsAwarded,
    required this.attemptNumber,
    required this.passingScore,
    required this.attemptsUsed,
    required this.attemptsRemaining,
    required this.pointsAwardedNow,
    required this.pointsAwardedAmount,
    required this.pointsPreviouslyAwarded,
    this.submittedAt,
  });
  factory QuizResult.fromJson(Map<String, Object?> json) => QuizResult(
    attemptId: json['id'] as int,
    quizId: json['quiz_id'] as int,
    score: json['score'] as int,
    totalQuestions: json['total_questions'] as int,
    isPassed: json['is_passed'] == true,
    pointsAwarded: json['points_awarded'] == true,
    attemptNumber: json['attempt_number'] as int,
    submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? ''),
    passingScore: json['passing_score'] as int,
    attemptsUsed: json['attempts_used'] as int,
    attemptsRemaining: json['attempts_remaining'] as int,
    pointsAwardedNow: json['points_awarded_now'] == true,
    pointsAwardedAmount: json['points_awarded_amount'] as int? ?? 0,
    pointsPreviouslyAwarded: json['points_previously_awarded'] == true,
  );
  final int attemptId;
  final int quizId;
  final int score;
  final int totalQuestions;
  final bool isPassed;
  final bool pointsAwarded;
  final int attemptNumber;
  final DateTime? submittedAt;
  final int passingScore;
  final int attemptsUsed;
  final int attemptsRemaining;
  final bool pointsAwardedNow;
  final int pointsAwardedAmount;
  final bool pointsPreviouslyAwarded;
  bool get canRetry => !isPassed && attemptsRemaining > 0;
}
