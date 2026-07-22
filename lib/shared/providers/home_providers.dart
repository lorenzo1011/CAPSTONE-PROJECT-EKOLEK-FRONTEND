import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/home/providers/home_controller.dart';
import '../../features/home/providers/home_state.dart';
import '../../features/wallet/services/wallet_service.dart';
import '../../features/wallet/providers/wallet_activity_controller.dart';
import '../../features/auth/providers/auth_state.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final walletServiceProvider = Provider<WalletService>(
  (ref) => WalletService(ref.watch(apiClientProvider)),
);
final homeControllerProvider = ChangeNotifierProvider<HomeController>((ref) {
  final controller = HomeController(ref.watch(walletServiceProvider));
  ref.listen(authenticationStateProvider, (previous, next) {
    if (next.status != AuthenticationStatus.authenticated ||
        previous?.user?.id != next.user?.id) {
      controller.reset();
    }
  });
  return controller;
});
final homeStateProvider = Provider<HomeState>(
  (ref) => ref.watch(homeControllerProvider).state,
);
final walletActivityControllerProvider =
    ChangeNotifierProvider.autoDispose<WalletActivityController>(
      (ref) => WalletActivityController(ref.watch(walletServiceProvider)),
    );
