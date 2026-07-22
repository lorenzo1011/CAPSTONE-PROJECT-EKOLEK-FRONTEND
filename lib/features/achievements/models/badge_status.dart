import 'package:flutter/material.dart';

enum BadgeStatus {
  locked('Locked', Icons.lock_outline_rounded),
  inProgress('In progress', Icons.trending_up_rounded),
  unlocked('Unlocked', Icons.verified_rounded),
  unknown('Unavailable', Icons.help_outline_rounded);

  const BadgeStatus(this.label, this.icon);
  final String label;
  final IconData icon;

  static BadgeStatus fromJson(Object? value) => switch (value) {
    'LOCKED' => locked,
    'IN_PROGRESS' => inProgress,
    'UNLOCKED' => unlocked,
    _ => unknown,
  };

  bool get isUnlocked => this == unlocked;
}
