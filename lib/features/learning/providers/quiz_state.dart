import '../models/quiz_answer.dart';
import '../models/quiz_detail.dart';
import '../models/quiz_result.dart';

enum QuizPhase {
  initial,
  loading,
  ready,
  inProgress,
  reviewing,
  submitting,
  passed,
  failed,
  exhausted,
  locked,
  offline,
  failure,
}

class QuizState {
  const QuizState({
    this.phase = QuizPhase.initial,
    this.quiz,
    this.currentIndex = 0,
    this.answers = const {},
    this.result,
    this.message,
  });
  final QuizPhase phase;
  final QuizDetail? quiz;
  final int currentIndex;
  final Map<int, QuizAnswer> answers;
  final QuizResult? result;
  final String? message;
  int get answeredCount => answers.length;
  int get unansweredCount => (quiz?.questions.length ?? 0) - answeredCount;
  bool get allAnswered => quiz != null && unansweredCount == 0;
  QuizState copyWith({
    QuizPhase? phase,
    QuizDetail? quiz,
    int? currentIndex,
    Map<int, QuizAnswer>? answers,
    QuizResult? result,
    String? message,
    bool clearMessage = false,
    bool clearResult = false,
  }) => QuizState(
    phase: phase ?? this.phase,
    quiz: quiz ?? this.quiz,
    currentIndex: currentIndex ?? this.currentIndex,
    answers: answers ?? this.answers,
    result: clearResult ? null : result ?? this.result,
    message: clearMessage ? null : message ?? this.message,
  );
}
