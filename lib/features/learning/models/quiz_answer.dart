class QuizAnswer {
  const QuizAnswer({required this.questionId, required this.selectedChoiceId});
  final int questionId;
  final int selectedChoiceId;
  Map<String, int> toRequestJson() => {
    'question': questionId,
    'selected_choice': selectedChoiceId,
  };
}
