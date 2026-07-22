import 'package:flutter/material.dart';

enum ChallengeStatus {
  upcoming,
  active,
  expired,
  inactive,
  unknown;

  factory ChallengeStatus.fromBackend(Object? value) => switch (value) {
    'UPCOMING' => upcoming,
    'ACTIVE' => active,
    'EXPIRED' => expired,
    'INACTIVE' => inactive,
    _ => unknown,
  };

  String get label => switch (this) {
    upcoming => 'Upcoming',
    active => 'Active',
    expired => 'Ended',
    inactive => 'Unavailable',
    unknown => 'Status unavailable',
  };

  IconData get icon => switch (this) {
    upcoming => Icons.schedule_rounded,
    active => Icons.flag_circle_rounded,
    expired => Icons.event_busy_rounded,
    inactive => Icons.block_rounded,
    unknown => Icons.help_outline_rounded,
  };
}
