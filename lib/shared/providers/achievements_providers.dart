import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/achievements/models/achievement_badge.dart';
import '../../features/achievements/providers/achievements_controller.dart';
import '../../features/achievements/providers/achievements_state.dart';
import '../../features/achievements/services/achievements_service.dart';
import '../../features/auth/providers/auth_state.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final achievementsServiceProvider = Provider<AchievementsService>(
  (ref) => AchievementsService(ref.watch(apiClientProvider)),
);
final achievementDetailProvider = FutureProvider.autoDispose
    .family<AchievementBadge, int>(
      (ref, id) => ref.watch(achievementsServiceProvider).getBadge(id),
    );
final achievementsControllerProvider =
    ChangeNotifierProvider<AchievementsController>((ref) {
      final controller = AchievementsController(
        ref.watch(achievementsServiceProvider),
      );
      ref.listen(authenticationStateProvider, (previous, next) {
        if (next.status != AuthenticationStatus.authenticated ||
            previous?.user?.id != next.user?.id) {
          controller.reset();
        }
      });
      return controller;
    });
final achievementsStateProvider = Provider<AchievementsState>(
  (ref) => ref.watch(achievementsControllerProvider).state,
);
