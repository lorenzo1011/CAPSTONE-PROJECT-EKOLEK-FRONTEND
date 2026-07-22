import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/challenges_providers.dart';
import '../models/eco_challenge.dart';
import '../widgets/challenge_detail_skeleton.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});
  final int challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(challengeDetailProvider(challengeId));
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge details')),
      body: detail.when(
        loading: () => const ChallengeDetailSkeleton(),
        error: (_, _) => AppErrorView(
          title: 'Challenge unavailable',
          message: 'This eco challenge is no longer available.',
          retryLabel: 'Try again',
          onRetry: () => ref.invalidate(challengeDetailProvider(challengeId)),
        ),
        data: (challenge) => _Detail(challenge: challenge),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.challenge});
  final EcoChallenge challenge;
  @override
  Widget build(BuildContext context) {
    final progress = challenge.progress;
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(challenge.type.icon, size: 30),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(challenge.type.label),
                      ],
                    ),
                  ),
                  Chip(
                    avatar: Icon(challenge.status.icon, size: 18),
                    label: Text(challenge.status.label),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (challenge.description.isNotEmpty)
                Text(
                  challenge.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (progress == null)
                        const Text(
                          'No progress has been recorded for this challenge yet.',
                        )
                      else ...[
                        Semantics(
                          label:
                              '${progress.currentValue} out of ${challenge.targetValue} ${challenge.goalUnit}',
                          child: LinearProgressIndicator(
                            value: progress.displayPercentage / 100,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${AppFormatters.challengeValue(progress.currentValue, challenge.goalUnit)} of '
                          '${AppFormatters.challengeValue(challenge.targetValue, challenge.goalUnit)} '
                          '(${AppFormatters.challengePercentage(progress.percentage)})',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.date_range_rounded),
                      title: const Text('Challenge period'),
                      subtitle: Text(
                        AppFormatters.challengeDateRange(
                          challenge.startDate,
                          challenge.endDate,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.public_rounded),
                      title: Text(
                        challenge.isCityWide
                            ? 'City-wide'
                            : 'Available for your barangay',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.workspace_premium_rounded),
                      title: Text(
                        challenge.bonusPoints > 0
                            ? AppFormatters.pointReward(challenge.bonusPoints)
                            : 'No point reward configured',
                      ),
                      subtitle: progress?.pointsAwarded == true
                          ? const Text('Reward issued by E-KOLEK')
                          : const Text(
                              'Rewards are processed by the verified backend workflow.',
                            ),
                    ),
                  ],
                ),
              ),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Participation updates automatically'),
                  subtitle: Text(
                    'This challenge does not currently provide resident Join, Leave, or Claim actions.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
