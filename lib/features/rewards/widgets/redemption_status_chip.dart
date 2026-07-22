import 'package:flutter/material.dart';
import '../models/redemption_status.dart';

class RedemptionStatusChip extends StatelessWidget {
  const RedemptionStatusChip({super.key, required this.status});
  final RedemptionStatus status;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Redemption status: ${status.label}',
    child: Chip(avatar: Icon(status.icon, size: 18), label: Text(status.label)),
  );
}
