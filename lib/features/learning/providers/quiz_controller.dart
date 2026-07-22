import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../models/quiz_answer.dart';
import '../models/quiz_result.dart';
import '../services/quiz_service.dart';
import 'quiz_state.dart';

class QuizController extends ChangeNotifier {
  QuizController(this._service, this.quizId);
  final QuizService _service;
  final int quizId;
  QuizState state = const QuizState();
  CancelToken? _token;
  bool _submitting = false;

  Future<void> load() async {
    if (state.phase == QuizPhase.loading) return;
    state = state.copyWith(phase: QuizPhase.loading, clearMessage: true);
    notifyListeners();
    _token = CancelToken();
    try {
      final quiz = await _service.getQuiz(quizId, cancelToken: _token);
      if (quiz.questions.isEmpty || quiz.hasUnsupportedQuestions) {
        state = state.copyWith(
          phase: QuizPhase.failure,
          quiz: quiz,
          message: 'This quiz contains an unsupported or unavailable question.',
        );
      } else if (!quiz.canAttempt) {
        state = state.copyWith(
          phase: QuizPhase.exhausted,
          quiz: quiz,
          message: 'No additional attempts are available for this quiz.',
        );
      } else {
        state = state.copyWith(
          phase: QuizPhase.ready,
          quiz: quiz,
          clearMessage: true,
        );
      }
    } on NoInternetException {
      state = state.copyWith(
        phase: QuizPhase.offline,
        message:
            'You appear to be offline. Connect to the internet to continue.',
      );
    } on ForbiddenException {
      state = state.copyWith(
        phase: QuizPhase.locked,
        message:
            'Complete the required learning activity before taking this quiz.',
      );
    } on AppException {
      state = state.copyWith(
        phase: QuizPhase.failure,
        message: 'This quiz is currently unavailable.',
      );
    }
    notifyListeners();
  }

  void start() {
    if (state.phase != QuizPhase.ready || state.quiz?.canAttempt != true) {
      return;
    }
    state = state.copyWith(
      phase: QuizPhase.inProgress,
      currentIndex: 0,
      answers: const {},
      clearResult: true,
      clearMessage: true,
    );
    notifyListeners();
  }

  void selectChoice(int questionId, int choiceId) {
    if (state.phase != QuizPhase.inProgress &&
        state.phase != QuizPhase.reviewing) {
      return;
    }
    final question = state.quiz?.questions
        .where((item) => item.id == questionId)
        .firstOrNull;
    if (question == null ||
        !question.isSupported ||
        !question.choices.any((choice) => choice.id == choiceId)) {
      return;
    }
    state = state.copyWith(
      answers: {
        ...state.answers,
        questionId: QuizAnswer(
          questionId: questionId,
          selectedChoiceId: choiceId,
        ),
      },
    );
    notifyListeners();
  }

  void goTo(int index) {
    final length = state.quiz?.questions.length ?? 0;
    if (index < 0 || index >= length) return;
    state = state.copyWith(currentIndex: index, phase: QuizPhase.inProgress);
    notifyListeners();
  }

  void review() {
    if (state.phase == QuizPhase.inProgress) {
      state = state.copyWith(phase: QuizPhase.reviewing);
      notifyListeners();
    }
  }

  void goToFirstUnanswered() {
    final questions = state.quiz?.questions ?? const [];
    final index = questions.indexWhere(
      (question) => !state.answers.containsKey(question.id),
    );
    if (index >= 0) goTo(index);
  }

  Future<QuizResult?> submit() async {
    if (_submitting ||
        state.phase != QuizPhase.reviewing ||
        !state.allAnswered) {
      return null;
    }
    _submitting = true;
    state = state.copyWith(phase: QuizPhase.submitting, clearMessage: true);
    notifyListeners();
    try {
      final orderedAnswers = [
        for (final question in state.quiz!.questions)
          state.answers[question.id]!,
      ];
      final result = await _service.submitQuiz(quizId, orderedAnswers);
      final phase = result.isPassed
          ? QuizPhase.passed
          : result.attemptsRemaining > 0
          ? QuizPhase.failed
          : QuizPhase.exhausted;
      state = state.copyWith(phase: phase, result: result);
      return result;
    } on NoInternetException {
      state = state.copyWith(
        phase: QuizPhase.reviewing,
        message:
            'Your quiz attempt could not be submitted. Check your connection and try again.',
      );
    } on AppException {
      state = state.copyWith(
        phase: QuizPhase.reviewing,
        message: 'E-KOLEK is temporarily unable to process this quiz.',
      );
    } finally {
      _submitting = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> retry() async {
    final result = state.result;
    if (result == null || !result.canRetry) return;
    state = const QuizState();
    await load();
  }

  void reset() {
    _token?.cancel();
    state = const QuizState();
    notifyListeners();
  }

  @override
  void dispose() {
    _token?.cancel();
    super.dispose();
  }
}
