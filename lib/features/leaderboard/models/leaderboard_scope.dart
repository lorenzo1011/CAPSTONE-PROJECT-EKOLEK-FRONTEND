import 'package:flutter/material.dart';

enum LeaderboardScope {
  barangayResidents(
    'BARANGAY_RESIDENTS',
    'Residents',
    Icons.people_outline_rounded,
  ),
  cityBarangays('CITY_BARANGAYS', 'Barangays', Icons.location_city_rounded),
  unknown('UNKNOWN', 'Unavailable', Icons.help_outline_rounded);

  const LeaderboardScope(this.value, this.label, this.icon);
  final String value, label;
  final IconData icon;
  static LeaderboardScope fromJson(Object? value) =>
      LeaderboardScope.values.firstWhere(
        (item) => item.value == value,
        orElse: () => LeaderboardScope.unknown,
      );
}
