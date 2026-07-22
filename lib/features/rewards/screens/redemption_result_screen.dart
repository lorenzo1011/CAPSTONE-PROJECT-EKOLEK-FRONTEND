import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/redemption_request_result.dart';
import '../widgets/redemption_status_chip.dart';
import 'package:go_router/go_router.dart';

class RedemptionResultScreen extends StatelessWidget {
  const RedemptionResultScreen({super.key, required this.result});
  final RedemptionRequestResult result;
  @override
  Widget build(BuildContext context) {
    final r = result.redemption;
    return Scaffold(
      appBar: AppBar(title: const Text('Request submitted')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    result.duplicateRequest
                        ? Icons.info_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 72,
                  ),
                  Text(
                    result.duplicateRequest
                        ? 'Existing request found'
                        : 'Redemption request submitted',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text(
                    'This request is not proof of physical reward release.',
                    textAlign: TextAlign.center,
                  ),
                  if (r.referenceCode != null)
                    Semantics(
                      label:
                          'Reference ${r.referenceCode!.split('').join(' ')}',
                      child: SelectableText(
                        r.referenceCode!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  RedemptionStatusChip(status: r.status),
                  ListTile(
                    title: Text(r.item.rewardName),
                    subtitle: Text('${r.item.quantity} item(s)'),
                    trailing: Text(
                      AppFormatters.rewardPoints(r.item.totalPoints),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Points not deducted'),
                    subtitle: const Text(
                      'Points are finalized only after authorized physical release.',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Barangay stock reserved'),
                    subtitle: const Text(
                      'The reservation follows the backend request status.',
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        context.go(AppRoutes.redemptionDetailPath(r.id)),
                    child: const Text('View request details'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        context.go(AppRoutes.redemptionHistoryPath),
                    child: const Text('View all requests'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
