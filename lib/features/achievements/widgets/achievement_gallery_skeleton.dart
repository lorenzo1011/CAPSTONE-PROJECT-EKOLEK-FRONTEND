import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class AchievementGallerySkeleton extends StatelessWidget {
  const AchievementGallerySkeleton({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900
          ? 4
          : constraints.maxWidth >= 600
          ? 3
          : 2;
      return Padding(
        padding: AppSpacing.screenPadding,
        child: GridView.builder(
          itemCount: columns * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: .72,
          ),
          itemBuilder: (context, index) => const AppSkeleton(height: 240),
        ),
      );
    },
  );
}
