import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../wallet/models/wallet_summary.dart';

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({super.key, required this.wallet});
  final WalletSummary wallet;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Available point balance ${wallet.currentBalance}',
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: DefaultTextStyle(
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Available points'),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              child: Text(
                AppFormatters.points(wallet.currentBalance),
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                Text('Earned ${AppFormatters.points(wallet.lifetimeEarned)}'),
                Text(
                  'Redeemed ${AppFormatters.points(wallet.lifetimeRedeemed)}',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
