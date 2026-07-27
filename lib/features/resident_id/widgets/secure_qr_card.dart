import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../models/digital_resident_id.dart';

class SecureQrCard extends StatelessWidget {
  const SecureQrCard({
    super.key,
    required this.id,
    this.onExpand,
    this.onRefresh,
    this.lastVerified,
    this.isRefreshing = false,
    this.compact = false,
    this.verifiedOnline = true,
  });

  final DigitalResidentId id;
  final VoidCallback? onExpand;
  final VoidCallback? onRefresh;
  final DateTime? lastVerified;
  final bool isRefreshing;
  final bool compact;
  final bool verifiedOnline;

  @override
  Widget build(BuildContext context) {
    final usable = id.canDisplayQr && verifiedOnline;
    final unavailableReason = verifiedOnline
        ? id.qrUnavailableReason
        : 'Reconnect and verify this ID with E-KOLEK before presenting its QR.';
    return Semantics(
      container: true,
      label: usable
          ? 'Active secure resident QR code for authorized E-KOLEK scanning.'
          : 'Secure resident QR code unavailable. $unavailableReason',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF084326), Color(0xFF147044)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure QR Verification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Backend-issued and revocable',
                          style: TextStyle(
                            color: Color(0xFFD4EBDD),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onRefresh != null)
                    IconButton(
                      tooltip: 'Verify QR status again',
                      onPressed: isRefreshing ? null : onRefresh,
                      color: Colors.white,
                      disabledColor: Colors.white54,
                      icon: isRefreshing
                          ? const SizedBox.square(
                              dimension: 19,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 16 : 20),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: usable
                        ? _QrCode(
                            key: ValueKey(id.qrIssuedAt ?? id.residentId),
                            payload: id.qrPayload!,
                            maxSize: compact ? 250 : 290,
                          )
                        : _UnavailableQr(
                            key: const ValueKey('unavailable'),
                            reason: unavailableReason,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    id.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    id.residentId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: usable
                          ? const Color(0xFFF0F8F3)
                          : AppColors.warningContainer.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          usable
                              ? Icons.shield_outlined
                              : Icons.info_outline_rounded,
                          color: usable ? AppColors.success : AppColors.warning,
                          size: 19,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            usable
                                ? 'Show only to authorized E-KOLEK personnel. The private verification value is never shown as text.'
                                : unavailableReason,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (lastVerified != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_done_outlined,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Checked with E-KOLEK ${DateFormat.jm().format(lastVerified!.toLocal())}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  if (usable && onExpand != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onExpand,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0B5A34),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.fullscreen_rounded),
                        label: const Text('Open scanner view'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCode extends StatelessWidget {
  const _QrCode({super.key, required this.payload, required this.maxSize});

  final String payload;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : maxSize;
        final size = available.clamp(0.0, maxSize);
        return Center(
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF0B5A34), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F052D1B),
                  blurRadius: 22,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: ExcludeSemantics(
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                padding: const EdgeInsets.all(8),
                gapless: true,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  color: Color(0xFF081C13),
                  eyeShape: QrEyeShape.square,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  color: Color(0xFF081C13),
                  dataModuleShape: QrDataModuleShape.square,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UnavailableQr extends StatelessWidget {
  const _UnavailableQr({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              size: 38,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Secure QR unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
