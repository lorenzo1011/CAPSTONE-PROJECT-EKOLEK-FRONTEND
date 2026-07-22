import 'package:flutter/material.dart';

enum ResidentIdStatus {
  active('Active', Icons.verified_rounded),
  pendingGeneration('Being prepared', Icons.hourglass_top_rounded),
  expired('Expired', Icons.event_busy_rounded),
  revoked('Deactivated', Icons.block_rounded),
  replacementPending('Replacement pending', Icons.sync_rounded),
  unavailable('Unavailable', Icons.badge_outlined),
  unknown('Status unavailable', Icons.help_outline_rounded);

  const ResidentIdStatus(this.label, this.icon);
  final String label;
  final IconData icon;

  static ResidentIdStatus fromContract({
    required Object? cardStatus,
    required bool qrIsActive,
    required bool hasResidentId,
  }) {
    final value = cardStatus?.toString().toUpperCase();
    if (!hasResidentId) return ResidentIdStatus.pendingGeneration;
    if (value == 'EXPIRED') return ResidentIdStatus.expired;
    if (value == 'REVOKED' || value == 'LOST') return ResidentIdStatus.revoked;
    if (value == 'REPLACED') return ResidentIdStatus.replacementPending;
    if ((value == null || value.isEmpty) && !qrIsActive) {
      return ResidentIdStatus.unavailable;
    }
    if ((value == null || value.isEmpty) && qrIsActive) {
      return ResidentIdStatus.active;
    }
    if (value == 'ACTIVE' && qrIsActive) return ResidentIdStatus.active;
    return ResidentIdStatus.unknown;
  }
}
