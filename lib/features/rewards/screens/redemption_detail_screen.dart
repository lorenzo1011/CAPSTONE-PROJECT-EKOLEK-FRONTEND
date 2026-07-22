import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/error_feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/redemption_providers.dart';
import '../models/redemption_status.dart';
import '../models/resident_redemption.dart';
import '../widgets/redemption_status_chip.dart';
import '../widgets/reward_image.dart';

class RedemptionDetailScreen extends ConsumerWidget {
  const RedemptionDetailScreen({super.key, required this.redemptionId});
  final int redemptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(redemptionDetailProvider(redemptionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Redemption request')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AppErrorView(
          title: 'Redemption unavailable',
          message: 'This redemption request is no longer available.',
          onRetry: () => ref.invalidate(redemptionDetailProvider(redemptionId)),
        ),
        data: (redemption) => _DetailBody(redemption: redemption),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.redemption});
  final ResidentRedemption redemption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = redemption;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(redemptionDetailProvider(r.id)),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: RewardImage(
                      name: r.item.rewardName,
                      url: r.item.imageUrl,
                    ),
                  ),
                  Text(
                    r.item.rewardName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  RedemptionStatusChip(status: r.status),
                  if (r.referenceCode != null)
                    ListTile(
                      title: const Text('Request reference'),
                      subtitle: SelectableText(r.referenceCode!),
                    ),
                  ListTile(
                    title: const Text('Quantity'),
                    trailing: Text('${r.item.quantity}'),
                  ),
                  ListTile(
                    title: const Text('Total points'),
                    trailing: Text(
                      AppFormatters.rewardPoints(r.item.totalPoints),
                    ),
                  ),
                  ListTile(
                    title: const Text('Requested'),
                    trailing: Text(AppFormatters.dateTime(r.requestedAt)),
                  ),
                  if (r.event != null)
                    ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: Text(r.event!.title),
                      subtitle: Text(
                        '${r.event!.location} · ${r.event!.barangayName ?? 'Barangay unavailable'}',
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status timeline',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const _Stage('Request submitted', true),
                          _Stage(
                            'Approved for distribution',
                            r.status == RedemptionStatus.approved ||
                                r.status == RedemptionStatus.completed,
                          ),
                          _Stage(
                            'Reward released',
                            r.status == RedemptionStatus.completed,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (r.cancellationAllowed)
                    OutlinedButton.icon(
                      onPressed: () => _cancel(context, ref, r),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel request'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    ResidentRedemption r,
  ) async {
    final confirmed = await ErrorFeedback.showConfirmation(
      context,
      title: 'Cancel request?',
      message:
          'The reserved stock will be released. No point refund is calculated by this app.',
      confirmLabel: 'Cancel request',
    );
    if (!confirmed) return;
    try {
      await ref.read(redemptionServiceProvider).cancel(r.id);
      ref.invalidate(redemptionDetailProvider(r.id));
      ref.read(redemptionHistoryControllerProvider).load(refresh: true);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This redemption request could not be cancelled.'),
          ),
        );
      }
    }
  }
}

class _Stage extends StatelessWidget {
  const _Stage(this.label, this.done);
  final String label;
  final bool done;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      done ? Icons.check_circle_outline : Icons.radio_button_unchecked,
    ),
    title: Text(label),
  );
}
