import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../wallet/models/point_transaction.dart';

class RecentPointActivity extends StatelessWidget {
  const RecentPointActivity({
    super.key,
    required this.items,
    this.maxItems = 4,
  });

  final List<PointTransaction> items;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyPointActivity();

    final visibleItems = items.take(maxItems).toList(growable: false);

    return Column(
      children: [
        for (var index = 0; index < visibleItems.length; index++) ...[
          _PointActivityRow(transaction: visibleItems[index]),
          if (index < visibleItems.length - 1)
            const Divider(indent: 72, endIndent: AppSpacing.md),
        ],
      ],
    );
  }
}

class _PointActivityRow extends StatelessWidget {
  const _PointActivityRow({required this.transaction});

  final PointTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spent = transaction.direction == PointDirection.spent;
    final accent = spent ? AppColors.spent : AppColors.earned;
    final sign = transaction.points > 0 ? '+' : '';

    return Semantics(
      container: true,
      label:
          '${transaction.direction.name} ${transaction.points.abs()} points, ${transaction.description.isEmpty ? transaction.label : transaction.description}',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.11),
                borderRadius: AppRadius.mediumBorderRadius,
              ),
              child: Icon(
                spent ? Icons.redeem_rounded : Icons.eco_rounded,
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.smMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isEmpty
                        ? transaction.label
                        : transaction.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppFormatters.dateTime(transaction.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smMd,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: AppRadius.circularBorderRadius,
              ),
              child: Text(
                '$sign${AppFormatters.points(transaction.points)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPointActivity extends StatelessWidget {
  const _EmptyPointActivity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Text(
            'No point activity yet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your verified earnings and redemptions will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
