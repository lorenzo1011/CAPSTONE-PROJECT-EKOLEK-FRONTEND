import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/learning/providers/learning_controller.dart';
import '../../features/learning/providers/learning_video_controller.dart';
import '../../features/learning/providers/quiz_controller.dart';
import '../../features/learning/services/learning_service.dart';
import '../../features/learning/services/quiz_service.dart';
import '../../features/auth/providers/auth_state.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final learningServiceProvider = Provider<LearningService>(
  (ref) => LearningService(ref.watch(apiClientProvider)),
);
final learningControllerProvider = ChangeNotifierProvider<LearningController>((
  ref,
) {
  final controller = LearningController(ref.watch(learningServiceProvider));
  ref.listen(authenticationStateProvider, (previous, next) {
    if (next.status != AuthenticationStatus.authenticated ||
        previous?.user?.id != next.user?.id) {
      controller.reset();
    }
  });
  return controller;
});
final learningVideoControllerProvider = ChangeNotifierProvider.autoDispose
    .family<LearningVideoController, int>((ref, id) {
      final controller = LearningVideoController(
        ref.watch(learningServiceProvider),
        id,
      );
      return controller;
    });

final quizServiceProvider = Provider<QuizService>(
  (ref) => QuizService(ref.watch(apiClientProvider)),
);
final quizControllerProvider = ChangeNotifierProvider.autoDispose
    .family<QuizController, int>((ref, id) {
      final controller = QuizController(ref.watch(quizServiceProvider), id);
      ref.listen(authenticationStateProvider, (previous, next) {
        if (next.status != AuthenticationStatus.authenticated ||
            previous?.user?.id != next.user?.id) {
          controller.reset();
        }
      });
      return controller;
    });
