import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/quiz_result.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.result});
  final QuizResult result;
  @override
  Widget build(BuildContext context) {
    final success = result.isPassed;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Icon(
                  success ? Icons.verified_rounded : Icons.school_rounded,
                  size: 76,
                  color: success
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 18),
                Text(
                  success ? 'Quiz passed' : 'Keep learning',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text('Backend-calculated score', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  '${result.score}%',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Passing requirement: ${result.passingScore}%',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _row('Attempt', '${result.attemptNumber}'),
                        _row('Questions submitted', '${result.totalQuestions}'),
                        _row(
                          'Attempts remaining',
                          '${result.attemptsRemaining}',
                        ),
                        if (result.pointsAwardedNow)
                          _row(
                            'Points awarded',
                            AppFormatters.pointReward(
                              result.pointsAwardedAmount,
                            ),
                          ),
                        if (result.pointsPreviouslyAwarded &&
                            !result.pointsAwardedNow)
                          _row('Quiz reward', 'Previously awarded'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (result.canRetry)
                  FilledButton.icon(
                    onPressed: () => context.go(
                      AppRoutes.learningQuizTakingPath(result.quizId),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.learnPath),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text('Return to Learn'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
