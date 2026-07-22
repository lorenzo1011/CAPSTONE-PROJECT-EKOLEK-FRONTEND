import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/events/providers/events_controller.dart';
import '../../features/events/services/events_service.dart';
import '../../features/auth/providers/auth_state.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final eventsServiceProvider = Provider<EventsService>(
  (ref) => EventsService(ref.watch(apiClientProvider)),
);
final eventsControllerProvider = ChangeNotifierProvider<EventsController>((
  ref,
) {
  final controller = EventsController(ref.watch(eventsServiceProvider));
  ref.listen(authenticationStateProvider, (previous, next) {
    if (next.status != AuthenticationStatus.authenticated ||
        previous?.user?.id != next.user?.id) {
      controller.reset();
    }
  });
  return controller;
});
