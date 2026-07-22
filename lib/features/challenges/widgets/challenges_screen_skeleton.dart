import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class ChallengesScreenSkeleton extends StatelessWidget {
  const ChallengesScreenSkeleton({super.key});
  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: AppSpacing.screenPadding,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 520,
      mainAxisExtent: 250,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
    ),
    itemCount: 4,
    itemBuilder: (_, _) => const AppSkeleton(height: 250),
  );
}
