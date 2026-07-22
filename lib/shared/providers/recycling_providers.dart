import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/recycling/providers/recycling_controller.dart';
import '../../features/recycling/providers/recycling_state.dart';
import '../../features/recycling/services/recycling_service.dart';
import '../../features/auth/providers/auth_state.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final recyclingServiceProvider = Provider<RecyclingService>(
  (ref) => RecyclingService(ref.watch(apiClientProvider)),
);
final recyclingControllerProvider = ChangeNotifierProvider<RecyclingController>(
  (ref) {
    final controller = RecyclingController(ref.watch(recyclingServiceProvider));
    ref.listen(authenticationStateProvider, (previous, next) {
      if (next.status != AuthenticationStatus.authenticated ||
          previous?.user?.id != next.user?.id) {
        controller.reset();
      }
    });
    return controller;
  },
);
final recyclingStateProvider = Provider<RecyclingState>(
  (ref) => ref.watch(recyclingControllerProvider).state,
);
