import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/auth/providers/auth_state.dart';
import '../../features/challenges/providers/challenges_controller.dart';
import '../../features/challenges/providers/challenges_state.dart';
import '../../features/challenges/services/challenges_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final challengesServiceProvider = Provider<ChallengesService>(
  (ref) => ChallengesService(ref.watch(apiClientProvider)),
);
final challengeDetailProvider = FutureProvider.autoDispose.family(
  (ref, int id) => ref.watch(challengesServiceProvider).getChallenge(id),
);
final challengesControllerProvider =
    ChangeNotifierProvider<ChallengesController>((ref) {
      final controller = ChallengesController(
        ref.watch(challengesServiceProvider),
      );
      ref.listen(authenticationStateProvider, (previous, next) {
        if (next.status != AuthenticationStatus.authenticated ||
            previous?.user?.id != next.user?.id) {
          controller.reset();
        }
      });
      return controller;
    });
final challengesStateProvider = Provider<ChallengesState>(
  (ref) => ref.watch(challengesControllerProvider).state,
);
