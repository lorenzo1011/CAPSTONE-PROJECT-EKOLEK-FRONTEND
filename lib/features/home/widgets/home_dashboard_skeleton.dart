import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      AppSkeleton(height: 90),
      SizedBox(height: AppSpacing.md),
      AppSkeleton(height: 190),
      SizedBox(height: AppSpacing.md),
      AppSkeleton(height: 120),
    ],
  );
}
