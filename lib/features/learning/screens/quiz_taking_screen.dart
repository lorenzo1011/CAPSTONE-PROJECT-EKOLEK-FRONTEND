import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/home_providers.dart';
import '../../../shared/providers/learning_providers.dart';
import '../providers/quiz_controller.dart';
import '../providers/quiz_state.dart';
import '../widgets/quiz_question_card.dart';
import '../widgets/quiz_taking_skeleton.dart';
import '../widgets/submit_quiz_dialog.dart';

class QuizTakingScreen extends ConsumerStatefulWidget {
  const QuizTakingScreen({super.key, required this.quizId});
  final int quizId;
  @override
  ConsumerState<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends ConsumerState<QuizTakingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(quizControllerProvider(widget.quizId)).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(quizControllerProvider(widget.quizId));
    final state = controller.state;
    final content = switch (state.phase) {
      QuizPhase.initial || QuizPhase.loading => const QuizTakingSkeleton(),
      QuizPhase.offline => AppOfflineView(onRetry: controller.load),
      QuizPhase.locked => AppErrorView(
        title: 'Quiz locked',
        message: state.message!,
        icon: Icons.lock_rounded,
      ),
      QuizPhase.failure => AppErrorView(
        title: 'Quiz unavailable',
        message: state.message ?? 'This quiz is currently unavailable.',
        retryLabel: 'Try again',
        onRetry: controller.load,
      ),
      QuizPhase.ready => _Ready(controller: controller),
      QuizPhase.inProgress => _Question(controller: controller),
      QuizPhase.reviewing || QuizPhase.submitting => _Review(
        controller: controller,
        submitting: state.phase == QuizPhase.submitting,
        onSubmit: () => _submit(controller),
      ),
      QuizPhase.exhausted => AppErrorView(
        title: 'Attempts exhausted',
        message:
            state.message ??
            'No additional attempts are available for this quiz.',
        icon: Icons.block_rounded,
      ),
      _ => const QuizTakingSkeleton(),
    };
    return Scaffold(
      appBar: AppBar(title: Text(state.quiz?.title ?? 'Quiz')),
      body: SafeArea(child: content),
    );
  }

  Future<void> _submit(QuizController controller) async {
    final confirmed = await showSubmitQuizDialog(
      context,
      unansweredCount: controller.state.unansweredCount,
    );
    if (!confirmed) return;
    final result = await controller.submit();
    if (!mounted || result == null) return;
    ref.read(learningControllerProvider).load(refresh: true);
    if (result.pointsAwardedNow) {
      final user = ref.read(currentAuthUserProvider);
      if (user != null) {
        ref.read(homeControllerProvider).load(user, refresh: true);
      }
      ref.invalidate(walletActivityControllerProvider);
    }
    context.go(AppRoutes.learningQuizResultPath(widget.quizId), extra: result);
  }
}

class _Ready extends StatelessWidget {
  const _Ready({required this.controller});
  final QuizController controller;
  @override
  Widget build(BuildContext context) {
    final quiz = controller.state.quiz!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz_rounded, size: 64),
              const SizedBox(height: 20),
              Text(
                '${quiz.questionCount} questions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Attempt ${quiz.attemptsUsed + 1} of ${quiz.maxAttempts} • Pass at ${quiz.passingScore}%',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: controller.start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Begin attempt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.controller});
  final QuizController controller;
  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final quiz = state.quiz!;
    final question = quiz.questions[state.currentIndex];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (state.currentIndex + 1) / quiz.questions.length,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: QuizQuestionCard(
                      key: ValueKey(question.id),
                      question: question,
                      questionNumber: state.currentIndex + 1,
                      totalQuestions: quiz.questions.length,
                      selectedChoiceId:
                          state.answers[question.id]?.selectedChoiceId,
                      onSelected: (id) =>
                          controller.selectChoice(question.id, id),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: state.currentIndex > 0
                        ? () => controller.goTo(state.currentIndex - 1)
                        : null,
                    child: const Text('Previous'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: state.currentIndex + 1 < quiz.questions.length
                        ? () => controller.goTo(state.currentIndex + 1)
                        : controller.review,
                    child: Text(
                      state.currentIndex + 1 < quiz.questions.length
                          ? 'Next'
                          : 'Review',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });
  final QuizController controller;
  final bool submitting;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final quiz = state.quiz!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Review your answers',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.unansweredCount == 0
                  ? 'All questions are answered.'
                  : '${state.unansweredCount} questions still need an answer.',
            ),
            if (state.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 20),
            for (var index = 0; index < quiz.questions.length; index++)
              Card(
                child: ListTile(
                  leading: Icon(
                    state.answers.containsKey(quiz.questions[index].id)
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                  ),
                  title: Text('Question ${index + 1}'),
                  subtitle: Text(
                    state.answers.containsKey(quiz.questions[index].id)
                        ? 'Answered'
                        : 'Unanswered',
                  ),
                  onTap: submitting ? null : () => controller.goTo(index),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: submitting || !state.allAnswered ? null : onSubmit,
              icon: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(submitting ? 'Submitting…' : 'Submit attempt'),
            ),
          ],
        ),
      ),
    );
  }
}
