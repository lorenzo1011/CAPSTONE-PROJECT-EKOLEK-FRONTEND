import 'quiz_question.dart';

class QuizDetail {
  const QuizDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.passingScore,
    required this.pointsReward,
    required this.maxAttempts,
    required this.questionCount,
    required this.attemptsUsed,
    required this.attemptsRemaining,
    required this.isPassed,
    required this.pointsPreviouslyAwarded,
    required this.canAttempt,
    required this.questions,
  });
  factory QuizDetail.fromJson(Map<String, Object?> json) {
    final raw = json['questions'];
    return QuizDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      passingScore: json['passing_score'] as int,
      pointsReward: json['points_reward'] as int,
      maxAttempts: json['max_attempts'] as int,
      questionCount: json['question_count'] as int,
      attemptsUsed: json['attempts_used'] as int,
      attemptsRemaining: json['attempts_remaining'] as int,
      isPassed: json['is_passed'] == true,
      pointsPreviouslyAwarded: json['points_previously_awarded'] == true,
      canAttempt: json['can_attempt'] == true,
      questions: raw is List
          ? raw
                .whereType<Map>()
                .map((item) => QuizQuestion.fromJson(_map(item)))
                .toList(growable: false)
          : const [],
    );
  }
  final int id;
  final String title;
  final String description;
  final int passingScore;
  final int pointsReward;
  final int maxAttempts;
  final int questionCount;
  final int attemptsUsed;
  final int attemptsRemaining;
  final bool isPassed;
  final bool pointsPreviouslyAwarded;
  final bool canAttempt;
  final List<QuizQuestion> questions;
  bool get hasUnsupportedQuestions =>
      questions.any((question) => !question.isSupported);
  static Map<String, Object?> _map(Map raw) =>
      raw.map((key, value) => MapEntry(key.toString(), value));
}
