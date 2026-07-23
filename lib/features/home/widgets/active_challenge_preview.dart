import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../challenges/models/eco_challenge.dart';

class ActiveChallengePreview extends StatelessWidget {
  const ActiveChallengePreview({super.key, required this.challenge});

  final EcoChallenge? challenge;

  @override
  Widget build(BuildContext context) {
    final item = challenge;
    if (item == null) return const _EmptyChallengeCard();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = item.progress;
    final percentage = (progress?.displayPercentage ?? 0)
        .clamp(0, 100)
        .toDouble();

    return Semantics(
      button: true,
      label: '${item.title}, ${percentage.round()} percent complete',
      hint: 'Open challenge details',
      child: Material(
        color: scheme.surface,
        borderRadius: AppRadius.largeBorderRadius,
        child: InkWell(
          onTap: () => context.push(AppRoutes.challengeDetailPath(item.id)),
          borderRadius: AppRadius.largeBorderRadius,
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.largeBorderRadius,
              border: Border.all(color: scheme.outlineVariant),
              gradient: LinearGradient(
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.52),
                  scheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: AppRadius.mediumBorderRadius,
                      ),
                      child: Icon(
                        item.type.icon,
                        color: scheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successContainer,
                              borderRadius: AppRadius.circularBorderRadius,
                            ),
                            child: Text(
                              'ACTIVE CHALLENGE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Text(
                        '${percentage.round()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.mdLg),
                ClipRRect(
                  borderRadius: AppRadius.circularBorderRadius,
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 9,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: AppSpacing.smMd),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        progress == null
                            ? 'Progress will appear after your first verified action.'
                            : '${AppFormatters.challengeValue(progress.currentValue, item.goalUnit)} of '
                                  '${AppFormatters.challengeValue(item.targetValue, item.goalUnit)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'View challenge',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: scheme.primary,
                      size: 18,
                    ),
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

class _EmptyChallengeCard extends StatelessWidget {
  const _EmptyChallengeCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: AppRadius.largeBorderRadius,
      child: InkWell(
        onTap: () => context.push(AppRoutes.challengesPath),
        borderRadius: AppRadius.largeBorderRadius,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.mdLg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.largeBorderRadius,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: AppRadius.mediumBorderRadius,
                ),
                child: Icon(
                  Icons.flag_outlined,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for your next eco goal?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Explore available challenges and start making measurable impact.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
