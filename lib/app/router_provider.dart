import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/providers/auth_providers.dart';
import 'router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter(
    authController: ref.read(authControllerProvider),
    accountStatusController: ref.read(accountStatusControllerProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});
