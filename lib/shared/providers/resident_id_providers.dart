import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/resident_id/models/digital_resident_id.dart';
import '../../features/resident_id/providers/resident_id_controller.dart';
import '../../features/resident_id/providers/resident_id_state.dart';
import '../../features/resident_id/services/resident_id_service.dart';
import 'auth_providers.dart';
import 'core_providers.dart';

final residentIdServiceProvider = Provider<ResidentIdService>(
  (ref) => ResidentIdService(ref.watch(apiClientProvider)),
);
final residentIdControllerProvider =
    ChangeNotifierProvider<ResidentIdController>((ref) {
      final controller = ResidentIdController(
        ref.watch(residentIdServiceProvider),
      );
      ref.listen(currentAuthUserProvider, (previous, user) {
        if (previous?.id != user?.id ||
            user == null ||
            !user.isApprovedResident) {
          controller.clear();
        }
      });
      return controller;
    });
final residentIdStateProvider = Provider<ResidentIdState>(
  (ref) => ref.watch(residentIdControllerProvider).state,
);
final currentDigitalResidentIdProvider = Provider<DigitalResidentId?>(
  (ref) => ref.watch(residentIdStateProvider).id,
);
