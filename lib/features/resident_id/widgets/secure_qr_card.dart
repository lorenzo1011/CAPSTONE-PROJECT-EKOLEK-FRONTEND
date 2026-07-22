import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/digital_resident_id.dart';

class SecureQrCard extends StatelessWidget {
  const SecureQrCard({super.key, required this.id, this.onExpand});
  final DigitalResidentId id;
  final VoidCallback? onExpand;
  @override
  Widget build(BuildContext context) {
    final usable = id.canDisplayQr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_2_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Secure QR',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (usable)
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth.clamp(0.0, 320.0);
                  return Center(
                    child: Semantics(
                      label:
                          'Secure resident QR code. Present for authorized scanning.',
                      image: true,
                      child: RepaintBoundary(
                        child: Container(
                          width: size,
                          height: size,
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: id.qrPayload!,
                            version: QrVersions.auto,
                            gapless: true,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              color: Colors.black,
                              eyeShape: QrEyeShape.square,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              color: Colors.black,
                              dataModuleShape: QrDataModuleShape.square,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_2_rounded, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Your secure QR code is currently unavailable.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            if (usable && onExpand != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onExpand,
                icon: const Icon(Icons.fullscreen_rounded),
                label: const Text('Show full screen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
