import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class GamesScreenSkeleton extends StatelessWidget {
  const GamesScreenSkeleton({super.key});
  @override
  Widget build(BuildContext context) => GridView.builder(
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 430,
      mainAxisExtent: 210,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
    ),
    itemCount: 4,
    itemBuilder: (_, _) => const AppSkeleton(height: 210),
  );
}
