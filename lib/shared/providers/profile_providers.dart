import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/profile/providers/profile_controller.dart';
import '../../features/profile/providers/profile_state.dart';
import '../../features/profile/services/profile_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.watch(apiClientProvider)),
);
final profileControllerProvider = ChangeNotifierProvider<ProfileController>((
  ref,
) {
  final c = ProfileController(ref.watch(profileServiceProvider));
  ref.listen(authenticationStateProvider, (previous, next) {
    if (next.status != AuthenticationStatus.authenticated ||
        previous?.user?.id != next.user?.id) {
      c.reset();
    }
  });
  return c;
});
final profileStateProvider = Provider<ProfileState>(
  (ref) => ref.watch(profileControllerProvider).state,
);
