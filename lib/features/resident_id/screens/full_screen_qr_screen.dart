import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/resident_id_providers.dart';
import '../widgets/secure_qr_card.dart';

class FullScreenQrScreen extends ConsumerWidget {
  const FullScreenQrScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(currentDigitalResidentIdProvider);
    if (id == null || !id.canDisplayQr) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Your secure QR code is currently unavailable.'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Secure QR')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SecureQrCard(id: id),
            ),
          ),
        ),
      ),
    );
  }
}
