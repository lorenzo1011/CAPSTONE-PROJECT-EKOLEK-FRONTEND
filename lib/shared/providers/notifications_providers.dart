import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/notifications/providers/notifications_controller.dart';
import '../../features/notifications/providers/notifications_state.dart';
import '../../features/notifications/services/notification_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.watch(apiClientProvider)),
);
final notificationDetailProvider = FutureProvider.autoDispose.family(
  (ref, int id) => ref.watch(notificationServiceProvider).getNotification(id),
);
final notificationsControllerProvider =
    ChangeNotifierProvider<NotificationsController>((ref) {
      final controller = NotificationsController(
        ref.watch(notificationServiceProvider),
      );
      ref.listen(authenticationStateProvider, (previous, next) {
        if (next.status != AuthenticationStatus.authenticated ||
            previous?.user?.id != next.user?.id) {
          controller.reset();
        }
      });
      return controller;
    });
final notificationsStateProvider = Provider<NotificationsState>(
  (ref) => ref.watch(notificationsControllerProvider).state,
);
final unreadNotificationCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsStateProvider).unreadCount,
);
