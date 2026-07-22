import 'package:flutter/material.dart';

enum RedemptionStatus {
  pending,
  approved,
  completed,
  cancelled,
  expired,
  unknown,
}

extension RedemptionStatusX on RedemptionStatus {
  static RedemptionStatus parse(Object? value) => switch (value) {
    'PENDING' => RedemptionStatus.pending,
    'APPROVED' => RedemptionStatus.approved,
    'CLAIMED' => RedemptionStatus.completed,
    'CANCELLED' => RedemptionStatus.cancelled,
    'EXPIRED' => RedemptionStatus.expired,
    _ => RedemptionStatus.unknown,
  };
  String get label => switch (this) {
    RedemptionStatus.pending => 'Pending processing',
    RedemptionStatus.approved => 'Approved for distribution',
    RedemptionStatus.completed => 'Reward released',
    RedemptionStatus.cancelled => 'Cancelled',
    RedemptionStatus.expired => 'Expired',
    RedemptionStatus.unknown => 'Status unavailable',
  };
  IconData get icon => switch (this) {
    RedemptionStatus.pending => Icons.schedule_rounded,
    RedemptionStatus.approved => Icons.verified_outlined,
    RedemptionStatus.completed => Icons.inventory_2_outlined,
    RedemptionStatus.cancelled => Icons.cancel_outlined,
    RedemptionStatus.expired => Icons.timer_off_outlined,
    RedemptionStatus.unknown => Icons.help_outline_rounded,
  };
  bool get isActive =>
      this == RedemptionStatus.pending || this == RedemptionStatus.approved;
}
