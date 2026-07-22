import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../challenges/models/eco_challenge.dart';

class ActiveChallengePreview extends StatelessWidget {
  const ActiveChallengePreview({super.key, required this.challenge});
  final EcoChallenge? challenge;

  @override
  Widget build(BuildContext context) {
    final item = challenge;
    if (item == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: const Text('Eco challenges'),
          subtitle: const Text(
            'No active eco challenge is currently available for your account.',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.challengesPath),
        ),
      );
    }
    final progress = item.progress;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.challengeDetailPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.type.icon),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              if (progress != null) ...[
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progress.displayPercentage / 100,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${AppFormatters.challengeValue(progress.currentValue, item.goalUnit)} of '
                  '${AppFormatters.challengeValue(item.targetValue, item.goalUnit)}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
