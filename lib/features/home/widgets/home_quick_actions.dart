import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.qr_code_scanner_rounded,
        'Scan QR',
        () => context.push(AppRoutes.residentIdQrPath),
      ),
      (
        Icons.badge_rounded,
        'My ID',
        () => context.push(AppRoutes.residentIdPath),
      ),
      (
        Icons.card_giftcard_rounded,
        'Redeem',
        () => context.go(AppRoutes.rewardsPath),
      ),
      (
        Icons.history_rounded,
        'History',
        () => context.push(AppRoutes.walletActivityPath),
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Action(
              icon: actions[i].$1,
              label: actions[i].$2,
              onTap: actions[i].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: const Color(0xFFF7F3FF),
        borderRadius: AppRadius.mediumBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumBorderRadius,
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: Icon(icon, color: AppColors.primary, size: 25),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      FittedBox(
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    ],
  );
}
