import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/games/providers/games_controller.dart';
import '../../features/games/services/game_registry.dart';
import '../../features/games/services/games_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final gamesServiceProvider = Provider<GamesService>(
  (ref) => GamesService(ref.watch(apiClientProvider)),
);
final gameRegistryProvider = Provider<GameRegistry>(
  (ref) => const GameRegistry(),
);
final gameDetailProvider = FutureProvider.autoDispose.family(
  (ref, int id) => ref.watch(gamesServiceProvider).getGame(id),
);
final gamesControllerProvider = ChangeNotifierProvider<GamesController>((ref) {
  final controller = GamesController(ref.watch(gamesServiceProvider));
  ref.listen(authenticationStateProvider, (previous, next) {
    if (next.status != AuthenticationStatus.authenticated ||
        previous?.user?.id != next.user?.id) {
      controller.reset();
    }
  });
  return controller;
});
