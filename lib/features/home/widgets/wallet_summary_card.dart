import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../wallet/models/wallet_summary.dart';

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({super.key, required this.wallet});

  final WalletSummary wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Available point balance ${wallet.currentBalance}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: AppRadius.extraLargeBorderRadius,
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mediumBorderRadius,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.smMd),
                Expanded(
                  child: Text(
                    'E-KOLEK wallet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push(AppRoutes.walletActivityPath),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onBrandMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                  label: const Text('Activity'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'AVAILABLE BALANCE',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onBrandMuted,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppFormatters.points(wallet.currentBalance),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 7, left: AppSpacing.sm),
                  child: Text(
                    'points',
                    style: TextStyle(color: AppColors.onBrandMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.08),
                borderRadius: AppRadius.largeBorderRadius,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _WalletMetric(
                      label: 'Lifetime earned',
                      value: AppFormatters.points(wallet.lifetimeEarned),
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: AppColors.white.withValues(alpha: 0.14),
                  ),
                  Expanded(
                    child: _WalletMetric(
                      label: 'Redeemed',
                      value: AppFormatters.points(wallet.lifetimeRedeemed),
                      icon: Icons.redeem_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    child: Row(
      children: [
        Icon(icon, color: AppColors.onBrandMuted, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppColors.white),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.onBrandMuted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
