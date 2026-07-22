import 'package:flutter/material.dart';

enum RewardAvailability { available, outOfStock, unavailable, unknown }

extension RewardAvailabilityX on RewardAvailability {
  static RewardAvailability parse(Object? value) => switch (value) {
    'AVAILABLE' => RewardAvailability.available,
    'OUT_OF_STOCK' => RewardAvailability.outOfStock,
    'UNAVAILABLE' => RewardAvailability.unavailable,
    _ => RewardAvailability.unknown,
  };
  bool get canPrepare => this == RewardAvailability.available;
  String get label => switch (this) {
    RewardAvailability.available => 'Available',
    RewardAvailability.outOfStock => 'Out of stock',
    RewardAvailability.unavailable => 'Unavailable',
    RewardAvailability.unknown => 'Availability unavailable',
  };
  IconData get icon => switch (this) {
    RewardAvailability.available => Icons.check_circle_outline_rounded,
    RewardAvailability.outOfStock => Icons.inventory_2_outlined,
    RewardAvailability.unavailable => Icons.block_rounded,
    RewardAvailability.unknown => Icons.help_outline_rounded,
  };
}
