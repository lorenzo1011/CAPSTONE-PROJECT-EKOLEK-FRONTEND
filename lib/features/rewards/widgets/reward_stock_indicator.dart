import 'package:flutter/material.dart';
import '../models/reward_availability.dart';

class RewardStockIndicator extends StatelessWidget {
  const RewardStockIndicator({
    super.key,
    required this.availability,
    required this.quantity,
  });
  final RewardAvailability availability;
  final int quantity;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${availability.label}. $quantity available in your barangay',
    child: Chip(
      avatar: Icon(availability.icon, size: 18),
      label: Text(
        availability == RewardAvailability.available
            ? '$quantity available'
            : availability.label,
      ),
    ),
  );
}
