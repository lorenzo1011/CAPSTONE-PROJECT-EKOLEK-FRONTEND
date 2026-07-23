import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../wallet/models/wallet_summary.dart';

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({super.key, required this.wallet});

  final WalletSummary wallet;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'E-KOLEK wallet balance ${wallet.currentBalance} points',
    child: Material(
      color: const Color(0xFFF0FAEE),
      borderRadius: AppRadius.largeBorderRadius,
      child: InkWell(
        onTap: () => context.push(AppRoutes.walletActivityPath),
        borderRadius: AppRadius.largeBorderRadius,
        child: Container(
          height: 154,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.largeBorderRadius,
            border: Border.all(color: const Color(0xFFDCEFD8)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -5,
                bottom: -25,
                width: 125,
                height: 125,
                child: Image.asset(
                  'assets/images/onboarding/home_wallet_points.png',
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF159447),
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'E-KOLEK Wallet',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: .8),
                          borderRadius: AppRadius.circularBorderRadius,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'View activity',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Available Balance',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: wallet.currentBalance.toDouble(),
                        ),
                        duration: AppMotion.accessible(context, AppMotion.slow),
                        builder: (context, value, child) => Text(
                          AppFormatters.points(value.round()),
                          style: AppTextStyles.metric.copyWith(
                            fontSize: 38,
                            color: const Color(0xFF087D3C),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 6),
                        child: Text(
                          'points',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
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
