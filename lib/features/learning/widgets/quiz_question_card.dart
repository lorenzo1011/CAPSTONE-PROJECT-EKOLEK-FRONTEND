import 'package:flutter/material.dart';

import '../models/quiz_question.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedChoiceId,
    required this.onSelected,
  });
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedChoiceId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Question $questionNumber of $totalQuestions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $questionNumber of $totalQuestions',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(question.text, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          RadioGroup<int>(
            groupValue: selectedChoiceId,
            onChanged: (value) {
              if (value != null) onSelected(value);
            },
            child: Column(
              children: [
                for (final choice in question.choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Semantics(
                      selected: selectedChoiceId == choice.id,
                      child: RadioListTile<int>(
                        value: choice.id,
                        title: Text(choice.text),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        selected: selectedChoiceId == choice.id,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
