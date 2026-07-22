enum QuizQuestionType {
  singleChoice,
  trueOrFalse,
  unknown;

  static QuizQuestionType fromBackend(Object? value) => switch (value) {
    'MULTIPLE_CHOICE' => QuizQuestionType.singleChoice,
    'TRUE_FALSE' => QuizQuestionType.trueOrFalse,
    _ => QuizQuestionType.unknown,
  };
}
