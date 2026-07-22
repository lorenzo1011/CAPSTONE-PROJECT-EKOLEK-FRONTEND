import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/api/auth_interceptor.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/auth_session_manager.dart';
import '../../core/auth/session_expired_handler.dart';
import '../../core/auth/token_refresh_service.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../core/storage/token_storage.dart';
import '../../core/storage/resident_status_storage.dart';
import '../../features/auth/models/account_status_info.dart';
import '../../features/auth/providers/account_status_controller.dart';
import '../../features/auth/providers/account_status_state.dart';
import '../../features/auth/services/account_status_service.dart';
import '../../features/auth/models/auth_user.dart';
import '../../features/auth/providers/auth_controller.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/services/password_service.dart';
import '../../features/auth/providers/password_controller.dart';
import 'core_providers.dart';

final secureTokenStorageProvider = Provider<SecureTokenStorage>(
  (ref) => SecureTokenStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => ref.watch(secureTokenStorageProvider),
);

final authSessionManagerProvider = Provider<AuthSessionManager>((ref) {
  final manager = AuthSessionManager(
    tokenStorage: ref.watch(tokenStorageProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

final sessionExpiredHandlerProvider = Provider<SessionExpiredHandler>((ref) {
  final handler = SessionExpiredHandler();
  ref.onDispose(handler.dispose);
  return handler;
});

final tokenRefreshServiceProvider = Provider<TokenRefreshService>((ref) {
  return TokenRefreshService(config: ref.watch(appConfigProvider));
});

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    config: ref.watch(appConfigProvider),
    sessionManager: ref.watch(authSessionManagerProvider),
    refreshService: ref.watch(tokenRefreshServiceProvider),
    sessionExpiredHandler: ref.watch(sessionExpiredHandlerProvider),
  );
});

final authSessionProvider = StreamProvider<AuthSession>((ref) async* {
  final manager = ref.watch(authSessionManagerProvider);
  yield manager.session;
  yield* manager.sessionStream;
});

final authSessionInitializationProvider = FutureProvider<AuthSession>((ref) {
  return ref.watch(authSessionManagerProvider).initialize();
});

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(apiClient: ref.watch(apiClientProvider)),
);

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(
    authService: ref.watch(authServiceProvider),
    sessionManager: ref.watch(authSessionManagerProvider),
    sessionExpiredHandler: ref.watch(sessionExpiredHandlerProvider),
    residentStatusStorage: ref.watch(residentStatusStorageProvider),
  );
});

final authenticationStateProvider = Provider<AuthenticationState>((ref) {
  return ref.watch(authControllerProvider).state;
});

final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authenticationStateProvider).user;
});

final residentStatusStorageProvider = Provider<ResidentStatusStorage>(
  (ref) => SecureResidentStatusStorage(),
);

final accountStatusServiceProvider = Provider<AccountStatusService>(
  (ref) => AccountStatusService(apiClient: ref.watch(apiClientProvider)),
);

final accountStatusControllerProvider =
    ChangeNotifierProvider<AccountStatusController>((ref) {
      return AccountStatusController(
        service: ref.watch(accountStatusServiceProvider),
        storage: ref.watch(residentStatusStorageProvider),
        authController: ref.watch(authControllerProvider),
      );
    });

final accountStatusStateProvider = Provider<AccountStatusState>(
  (ref) => ref.watch(accountStatusControllerProvider).state,
);

final currentAccountStatusInfoProvider = Provider<AccountStatusInfo?>(
  (ref) => ref.watch(accountStatusStateProvider).info,
);

final passwordServiceProvider = Provider<PasswordService>(
  (ref) => PasswordService(ref.watch(apiClientProvider)),
);
final passwordControllerProvider =
    ChangeNotifierProvider.autoDispose<PasswordController>(
      (ref) => PasswordController(ref.watch(passwordServiceProvider)),
    );
