import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_layout.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount:
          MediaQuery.sizeOf(context).width >= AppLayout.tabletBreakpoint
          ? 4
          : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.2,
      children: [
        _Action(
          Icons.badge_rounded,
          'Digital ID',
          onTap: () => context.push(AppRoutes.residentIdPath),
        ),
        _Action(
          Icons.event_rounded,
          'Schedules',
          onTap: () => context.push(AppRoutes.schedulesPath),
        ),
        _Action(
          Icons.recycling_rounded,
          'History',
          onTap: () => context.push(AppRoutes.recyclingPath),
        ),
        _Action(
          Icons.flag_rounded,
          'Challenges',
          onTap: () => context.push(AppRoutes.challengesPath),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, {required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumBorderRadius,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: AppSpacing.sm),
              Flexible(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}
