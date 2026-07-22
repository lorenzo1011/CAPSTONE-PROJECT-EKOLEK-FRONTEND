class QuizChoice {
  const QuizChoice({required this.id, required this.text, required this.order});

  factory QuizChoice.fromJson(Map<String, Object?> json) => QuizChoice(
    id: json['id'] as int,
    text: json['choice_text'] as String? ?? '',
    order: json['order'] as int? ?? 0,
  );

  final int id;
  final String text;
  final int order;
}
