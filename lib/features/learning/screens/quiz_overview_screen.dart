import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/learning_quiz_summary.dart';

class QuizOverviewScreen extends StatelessWidget {
  const QuizOverviewScreen({super.key, required this.quiz});
  final LearningQuizSummary quiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz overview')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Icon(
                  quiz.isUnlocked ? Icons.quiz_rounded : Icons.lock_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  quiz.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (quiz.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(quiz.description, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (quiz.questionCount != null)
                          _row('Questions', '${quiz.questionCount}'),
                        if (quiz.passingScore != null)
                          _row('Passing score', '${quiz.passingScore}%'),
                        if (quiz.pointsReward != null)
                          _row(
                            'Reward',
                            AppFormatters.pointReward(quiz.pointsReward),
                          ),
                        if (quiz.maxAttempts != null)
                          _row('Maximum attempts', '${quiz.maxAttempts}'),
                        if (quiz.attemptCount != null)
                          _row('Attempts used', '${quiz.attemptCount}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  quiz.isPassed
                      ? 'You have already passed this quiz. Additional attempts cannot award the same quiz reward again.'
                      : quiz.isUnlocked
                      ? 'Answer every question, review your selections, then submit them for backend grading.'
                      : 'Complete the related learning video to unlock this quiz.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed:
                      quiz.isUnlocked &&
                          (quiz.attemptCount ?? 0) < (quiz.maxAttempts ?? 0)
                      ? () => context.push(
                          AppRoutes.learningQuizTakingPath(quiz.id),
                        )
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(quiz.isPassed ? 'Take again' : 'Start quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
