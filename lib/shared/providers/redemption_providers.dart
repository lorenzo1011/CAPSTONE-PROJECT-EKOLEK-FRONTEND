import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/rewards/models/resident_redemption.dart';
import '../../features/rewards/providers/redemption_history_controller.dart';
import '../../features/rewards/providers/redemption_history_state.dart';
import '../../features/rewards/providers/redemption_submission_controller.dart';
import '../../features/rewards/services/redemption_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';
import 'rewards_providers.dart';

final redemptionServiceProvider = Provider<RedemptionService>(
  (ref) => RedemptionService(ref.watch(apiClientProvider)),
);
final redemptionSubmissionControllerProvider =
    ChangeNotifierProvider<RedemptionSubmissionController>((ref) {
      final c = RedemptionSubmissionController(
        ref.watch(redemptionServiceProvider),
        ref.watch(rewardsServiceProvider),
      );
      ref.listen(authenticationStateProvider, (previous, next) {
        if (next.status != AuthenticationStatus.authenticated ||
            previous?.user?.id != next.user?.id) {
          c.reset();
        }
      });
      return c;
    });
final redemptionHistoryControllerProvider =
    ChangeNotifierProvider<RedemptionHistoryController>((ref) {
      final c = RedemptionHistoryController(
        ref.watch(redemptionServiceProvider),
      );
      ref.listen(authenticationStateProvider, (previous, next) {
        if (next.status != AuthenticationStatus.authenticated ||
            previous?.user?.id != next.user?.id) {
          c.reset();
        }
      });
      return c;
    });
final redemptionHistoryStateProvider = Provider<RedemptionHistoryState>(
  (ref) => ref.watch(redemptionHistoryControllerProvider).state,
);
final redemptionDetailProvider = FutureProvider.autoDispose
    .family<ResidentRedemption, int>(
      (ref, id) => ref.watch(redemptionServiceProvider).detail(id),
    );
