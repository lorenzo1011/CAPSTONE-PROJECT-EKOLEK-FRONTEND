import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/leaderboard/providers/leaderboard_controller.dart';
import '../../features/leaderboard/providers/leaderboard_state.dart';
import '../../features/leaderboard/services/leaderboard_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final leaderboardServiceProvider = Provider<LeaderboardService>(
  (ref) => LeaderboardService(ref.watch(apiClientProvider)),
);
final leaderboardControllerProvider =
    ChangeNotifierProvider<LeaderboardController>((ref) {
      final controller = LeaderboardController(
        ref.watch(leaderboardServiceProvider),
      );
      ref.listen(authenticationStateProvider, (previous, next) {
        if (next.status != AuthenticationStatus.authenticated ||
            previous?.user?.id != next.user?.id) {
          controller.reset();
        }
      });
      return controller;
    });
final leaderboardStateProvider = Provider<LeaderboardState>(
  (ref) => ref.watch(leaderboardControllerProvider).state,
);
