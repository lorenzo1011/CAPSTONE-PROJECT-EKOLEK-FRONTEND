import 'quiz_choice.dart';
import 'quiz_question_type.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.order,
    required this.choices,
  });

  factory QuizQuestion.fromJson(Map<String, Object?> json) {
    final rawChoices = json['choices'];
    return QuizQuestion(
      id: json['id'] as int,
      text: json['question_text'] as String? ?? '',
      type: QuizQuestionType.fromBackend(json['question_type']),
      order: json['order'] as int? ?? 0,
      choices: rawChoices is List
          ? rawChoices
                .whereType<Map>()
                .map((item) => QuizChoice.fromJson(_map(item)))
                .toList(growable: false)
          : const [],
    );
  }

  final int id;
  final String text;
  final QuizQuestionType type;
  final int order;
  final List<QuizChoice> choices;
  bool get isSupported => type != QuizQuestionType.unknown;

  static Map<String, Object?> _map(Map raw) =>
      raw.map((key, value) => MapEntry(key.toString(), value));
}
