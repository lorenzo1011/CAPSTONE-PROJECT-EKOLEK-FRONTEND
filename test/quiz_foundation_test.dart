import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/learning/models/quiz_answer.dart';
import 'package:ekolek_app/features/learning/models/quiz_detail.dart';
import 'package:ekolek_app/features/learning/models/quiz_question_type.dart';
import 'package:ekolek_app/features/learning/models/quiz_result.dart';
import 'package:ekolek_app/features/learning/providers/quiz_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verified quiz contract', () {
    test('uses resident-safe overview and submission endpoints', () {
      expect(ApiEndpoints.learningQuiz(4), 'mobile/quizzes/4/');
      expect(ApiEndpoints.submitLearningQuiz(4), 'mobile/quizzes/4/submit/');
      expect(ApiEndpoints.submitLearningQuiz(4), isNot(contains('admin')));
    });

    test('maps only supported backend question types', () {
      expect(
        QuizQuestionType.fromBackend('MULTIPLE_CHOICE'),
        QuizQuestionType.singleChoice,
      );
      expect(
        QuizQuestionType.fromBackend('TRUE_FALSE'),
        QuizQuestionType.trueOrFalse,
      );
      expect(
        QuizQuestionType.fromBackend('MULTIPLE_SELECT'),
        QuizQuestionType.unknown,
      );
    });

    test('preserves backend question and choice ordering', () {
      final quiz = QuizDetail.fromJson(_quizJson());
      expect(quiz.questions.map((item) => item.id), [20, 10]);
      expect(quiz.questions.first.choices.map((item) => item.id), [202, 201]);
    });

    test('resident choices do not parse correctness metadata', () {
      final choice = QuizDetail.fromJson(
        _quizJson(),
      ).questions.first.choices.first;
      expect(choice.id, 202);
      expect(choice.toString(), isNot(contains('correct')));
    });

    test('answer payload contains no resident or correctness data', () {
      const answer = QuizAnswer(questionId: 20, selectedChoiceId: 202);
      expect(answer.toRequestJson(), {'question': 20, 'selected_choice': 202});
      expect(answer.toRequestJson(), isNot(containsPair('resident', anything)));
    });

    test('backend pass flag remains authoritative', () {
      final result = QuizResult.fromJson(
        _resultJson(score: 100, passed: false),
      );
      expect(result.score, 100);
      expect(result.isPassed, isFalse);
      expect(result.canRetry, isTrue);
    });

    test('points display requires newly awarded backend flag', () {
      final result = QuizResult.fromJson(_resultJson(score: 80, passed: true));
      expect(result.pointsAwarded, isTrue);
      expect(result.pointsAwardedNow, isFalse);
      expect(result.pointsPreviouslyAwarded, isTrue);
    });

    test('exhausted result cannot retry', () {
      final json = _resultJson(score: 40, passed: false)
        ..['attempts_remaining'] = 0;
      expect(QuizResult.fromJson(json).canRetry, isFalse);
    });

    test('quiz state counts local completion without grading', () {
      final quiz = QuizDetail.fromJson(_quizJson());
      final state = QuizState(
        quiz: quiz,
        answers: const {20: QuizAnswer(questionId: 20, selectedChoiceId: 202)},
      );
      expect(state.answeredCount, 1);
      expect(state.unansweredCount, 1);
      expect(state.allAnswered, isFalse);
    });
  });
}

Map<String, Object?> _quizJson() => {
  'id': 4,
  'title': 'Sorting quiz',
  'description': '',
  'passing_score': 75,
  'points_reward': 10,
  'max_attempts': 3,
  'question_count': 2,
  'attempts_used': 0,
  'attempts_remaining': 3,
  'is_passed': false,
  'points_previously_awarded': false,
  'can_attempt': true,
  'questions': [
    {
      'id': 20,
      'question_text': 'Second by server choice',
      'question_type': 'MULTIPLE_CHOICE',
      'order': 2,
      'choices': [
        {'id': 202, 'choice_text': 'B', 'order': 2, 'is_correct': true},
        {'id': 201, 'choice_text': 'A', 'order': 1, 'is_correct': false},
      ],
    },
    {
      'id': 10,
      'question_text': 'First by id',
      'question_type': 'TRUE_FALSE',
      'order': 1,
      'choices': [
        {'id': 101, 'choice_text': 'True', 'order': 1},
        {'id': 102, 'choice_text': 'False', 'order': 2},
      ],
    },
  ],
};

Map<String, Object?> _resultJson({required int score, required bool passed}) =>
    {
      'id': 7,
      'quiz_id': 4,
      'score': score,
      'total_questions': 2,
      'is_passed': passed,
      'points_awarded': true,
      'attempt_number': 2,
      'submitted_at': '2026-07-16T00:00:00Z',
      'passing_score': 75,
      'attempts_used': 2,
      'attempts_remaining': 1,
      'points_awarded_now': false,
      'points_awarded_amount': 0,
      'points_previously_awarded': true,
    };
