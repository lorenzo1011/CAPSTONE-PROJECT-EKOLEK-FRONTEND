import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/error_feedback.dart';
import '../../../shared/providers/redemption_providers.dart';
import '../providers/redemption_submission_state.dart';
import '../models/redemption_preparation.dart';
import '../widgets/reward_image.dart';

class RedemptionReviewScreen extends ConsumerWidget {
  const RedemptionReviewScreen({super.key, required this.preparation});
  final RedemptionPreparation preparation;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = preparation.reward, e = preparation.preview.eligibility;
    final submission = ref.watch(redemptionSubmissionControllerProvider).state;
    return Scaffold(
      appBar: AppBar(title: const Text('Redemption review')),
      body: ListView(
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
                    child: RewardImage(name: r.name, url: r.imageUrl),
                  ),
                  Text(
                    r.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _Row('Quantity', '${e.quantity}'),
                  _Row(
                    'Points per item',
                    AppFormatters.rewardPoints(e.pointsPerItem),
                  ),
                  _Row(
                    'Total points',
                    AppFormatters.rewardPoints(e.totalPoints),
                  ),
                  _Row(
                    'Wallet balance',
                    e.walletBalance == null
                        ? 'Unavailable'
                        : AppFormatters.rewardPoints(e.walletBalance!),
                  ),
                  _Row(
                    'Estimated remaining',
                    e.estimatedRemainingPoints == null
                        ? 'Unavailable'
                        : AppFormatters.rewardPoints(
                            e.estimatedRemainingPoints!,
                          ),
                  ),
                  if (preparation.event != null)
                    _Row('Reward event', preparation.event!.title),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text('Review only'),
                      subtitle: Text(
                        'No redemption, reservation, points deduction, or stock change has been made. Stock and points will be checked again during final confirmation in the next phase.',
                      ),
                    ),
                  ),
                  if (submission.message != null)
                    ListTile(
                      leading: Icon(
                        submission.phase == RedemptionSubmissionPhase.uncertain
                            ? Icons.sync_rounded
                            : Icons.info_outline_rounded,
                      ),
                      title: Text(submission.message!),
                    ),
                  FilledButton.icon(
                    onPressed: submission.busy
                        ? null
                        : () async {
                            final confirmed = await ErrorFeedback.showConfirmation(
                              context,
                              title: 'Submit redemption request?',
                              message:
                                  'E-KOLEK will recheck your points, barangay stock, quantity, and active reward event. This does not confirm physical release.',
                              confirmLabel: 'Submit request',
                            );
                            if (!confirmed || !context.mounted) return;
                            final result = await ref
                                .read(redemptionSubmissionControllerProvider)
                                .submit(preparation);
                            if (result != null && context.mounted) {
                              ref
                                  .read(redemptionHistoryControllerProvider)
                                  .load(refresh: true);
                              context.go(
                                AppRoutes.redemptionResultPath(
                                  result.redemption.id,
                                ),
                                extra: result,
                              );
                            }
                          },
                    icon: submission.busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      submission.phase == RedemptionSubmissionPhase.revalidating
                          ? 'Revalidating…'
                          : submission.phase ==
                                RedemptionSubmissionPhase.submitting
                          ? 'Submitting…'
                          : submission.phase ==
                                RedemptionSubmissionPhase.uncertain
                          ? 'Checking request…'
                          : 'Submit redemption request',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: submission.busy
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Back and edit'),
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

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Flexible(
      child: Text(
        value,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    ),
  );
}
