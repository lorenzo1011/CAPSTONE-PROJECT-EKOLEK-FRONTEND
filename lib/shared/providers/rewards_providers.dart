import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/rewards/providers/reward_detail_controller.dart';
import '../../features/rewards/providers/rewards_controller.dart';
import '../../features/rewards/providers/rewards_state.dart';
import '../../features/rewards/services/rewards_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final rewardsServiceProvider = Provider<RewardsService>(
  (ref) => RewardsService(ref.watch(apiClientProvider)),
);
final rewardsControllerProvider = ChangeNotifierProvider<RewardsController>((
  ref,
) {
  final c = RewardsController(ref.watch(rewardsServiceProvider));
  ref.listen(authenticationStateProvider, (previous, next) {
    if (next.status != AuthenticationStatus.authenticated ||
        previous?.user?.id != next.user?.id) {
      c.reset();
    }
  });
  return c;
});
final rewardsStateProvider = Provider<RewardsState>(
  (ref) => ref.watch(rewardsControllerProvider).state,
);
final rewardDetailControllerProvider = ChangeNotifierProvider.autoDispose
    .family<RewardDetailController, int>(
      (ref, id) =>
          RewardDetailController(ref.watch(rewardsServiceProvider), id),
    );
