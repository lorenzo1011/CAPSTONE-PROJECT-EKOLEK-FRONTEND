import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_layout.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  static const _items = [
    _ActionData(Icons.badge_outlined, 'Digital ID', 'Open your resident pass'),
    _ActionData(
      Icons.calendar_month_outlined,
      'Schedules',
      'Collection events',
    ),
    _ActionData(
      Icons.recycling_outlined,
      'Recycling',
      'View contribution history',
    ),
    _ActionData(Icons.flag_outlined, 'Challenges', 'Track active goals'),
  ];

  @override
  Widget build(BuildContext context) {
    final routes = [
      AppRoutes.residentIdPath,
      AppRoutes.schedulesPath,
      AppRoutes.recyclingPath,
      AppRoutes.challengesPath,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppLayout.tabletBreakpoint
            ? 4
            : 2;
        final width =
            (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            return SizedBox(
              width: width,
              child: AppCard(
                onTap: () => context.push(routes[index]),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: AppRadius.mediumBorderRadius,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          item.icon,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          size: AppLayout.iconMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ActionData {
  const _ActionData(this.icon, this.label, this.caption);
  final IconData icon;
  final String label;
  final String caption;
}
