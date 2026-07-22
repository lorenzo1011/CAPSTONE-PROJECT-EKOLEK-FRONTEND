import 'package:flutter/material.dart';
import '../models/redemption_eligibility.dart';

class RedemptionEligibilityCard extends StatelessWidget {
  const RedemptionEligibilityCard({
    super.key,
    this.value,
    required this.checking,
  });
  final RedemptionEligibility? value;
  final bool checking;
  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Checking eligibility'),
        ),
      );
    }
    final e = value;
    if (e == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.help_outline_rounded),
          title: Text('Eligibility unavailable'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                e.eligible
                    ? Icons.verified_outlined
                    : Icons.info_outline_rounded,
              ),
              title: Text(
                e.eligible ? 'Eligible for review' : 'Not eligible yet',
              ),
              subtitle: Text(e.reason),
            ),
            _Check('Points available', e.sufficientPoints),
            _Check('Barangay stock', e.stockAvailable),
            _Check('Quantity valid', e.quantityValid),
            _Check('Active reward event', e.eventEligible),
          ],
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check(this.label, this.ok);
  final String label;
  final bool ok;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(ok ? Icons.check_circle_outline : Icons.cancel_outlined, size: 20),
      const SizedBox(width: 8),
      Expanded(child: Text(label)),
    ],
  );
}
