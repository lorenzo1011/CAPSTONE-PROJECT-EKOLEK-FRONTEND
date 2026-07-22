import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class ChallengeDetailSkeleton extends StatelessWidget {
  const ChallengeDetailSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton(height: 44),
        SizedBox(height: AppSpacing.lg),
        AppSkeleton(height: 160),
        SizedBox(height: AppSpacing.md),
        AppSkeleton(height: 100),
      ],
    ),
  );
}
