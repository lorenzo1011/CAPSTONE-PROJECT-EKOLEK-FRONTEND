import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/eco_challenge.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
  });
  final EcoChallenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = challenge.progress;
    return Semantics(
      button: true,
      label: '${challenge.title}, ${challenge.status.label}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Icon(challenge.type.icon)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        challenge.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Chip(
                      avatar: Icon(challenge.status.icon, size: 18),
                      label: Text(challenge.status.label),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  challenge.description.isEmpty
                      ? challenge.type.label
                      : challenge.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (progress != null) ...[
                  Semantics(
                    label:
                        '${progress.currentValue} out of ${challenge.targetValue} ${challenge.goalUnit}',
                    child: LinearProgressIndicator(
                      value: progress.displayPercentage / 100,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${AppFormatters.challengeValue(progress.currentValue, challenge.goalUnit)} of '
                    '${AppFormatters.challengeValue(challenge.targetValue, challenge.goalUnit)}',
                  ),
                ] else
                  Text(
                    'Goal: ${AppFormatters.challengeValue(challenge.targetValue, challenge.goalUnit)}',
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        challenge.bonusPoints > 0
                            ? '${AppFormatters.points(challenge.bonusPoints)} point reward'
                            : 'No point reward configured',
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
