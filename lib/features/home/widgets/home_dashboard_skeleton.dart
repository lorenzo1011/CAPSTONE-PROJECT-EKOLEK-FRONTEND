import 'package:flutter/material.dart';

import '../../../app/theme/app_layout.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppLayout.dashboardBreakpoint;

        final primaryColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _SkeletonHeader(width: 170),
            SizedBox(height: AppSpacing.smMd),
            AppSkeleton(height: 190, borderRadius: AppRadius.large),
            SizedBox(height: AppSpacing.section),
            _SkeletonHeader(width: 190),
            SizedBox(height: AppSpacing.smMd),
            AppSkeleton(height: 272, borderRadius: AppRadius.large),
          ],
        );

        final secondaryColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _SkeletonHeader(width: 150),
            SizedBox(height: AppSpacing.smMd),
            AppSkeleton(height: 116, borderRadius: AppRadius.large),
            SizedBox(height: AppSpacing.lg),
            _SkeletonHeader(width: 170),
            SizedBox(height: AppSpacing.smMd),
            AppSkeleton(height: 116, borderRadius: AppRadius.large),
            SizedBox(height: AppSpacing.lg),
            AppSkeleton(height: 108, borderRadius: AppRadius.large),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSkeleton(height: 230, borderRadius: AppRadius.hero),
            const SizedBox(height: AppSpacing.md),
            const _QuickActionsSkeleton(),
            const SizedBox(height: AppSpacing.md),
            const AppSkeleton(height: 92, borderRadius: AppRadius.large),
            const SizedBox(height: AppSpacing.section),
            const _SkeletonHeader(width: 180),
            const SizedBox(height: AppSpacing.smMd),
            const _FeatureGridSkeleton(),
            const SizedBox(height: AppSpacing.section),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: primaryColumn),
                  const SizedBox(width: AppLayout.dashboardColumnGap),
                  Expanded(flex: 4, child: secondaryColumn),
                ],
              )
            else ...[
              primaryColumn,
              const SizedBox(height: AppSpacing.section),
              secondaryColumn,
            ],
          ],
        );
      },
    );
  }
}

class _QuickActionsSkeleton extends StatelessWidget {
  const _QuickActionsSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: AppSkeleton(height: 108, borderRadius: AppRadius.large)),
      SizedBox(width: AppSpacing.sm),
      Expanded(child: AppSkeleton(height: 108, borderRadius: AppRadius.large)),
      SizedBox(width: AppSpacing.sm),
      Expanded(child: AppSkeleton(height: 108, borderRadius: AppRadius.large)),
    ],
  );
}

class _FeatureGridSkeleton extends StatelessWidget {
  const _FeatureGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final width =
            (constraints.maxWidth - (columns - 1) * AppSpacing.smMd) / columns;

        return Wrap(
          spacing: AppSpacing.smMd,
          runSpacing: AppSpacing.smMd,
          children: List.generate(
            3,
            (_) => SizedBox(
              width: width,
              child: const AppSkeleton(
                height: 148,
                borderRadius: AppRadius.large,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSkeleton(width: width, height: 20, borderRadius: AppRadius.small),
      const SizedBox(height: AppSpacing.sm),
      const AppSkeleton(height: 13, borderRadius: AppRadius.small),
    ],
  );
}
