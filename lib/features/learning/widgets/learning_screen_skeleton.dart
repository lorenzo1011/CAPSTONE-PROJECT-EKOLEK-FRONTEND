import 'package:flutter/material.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../app/theme/app_spacing.dart';

class LearningScreenSkeleton extends StatelessWidget {
  const LearningScreenSkeleton({super.key});
  @override
  Widget build(BuildContext context) => ListView.separated(
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
    itemBuilder: (_, _) => const Row(
      children: [
        Expanded(flex: 2, child: AppSkeleton(height: 110)),
        SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(height: 20),
              SizedBox(height: 12),
              AppSkeleton(height: 14),
              SizedBox(height: 12),
              AppSkeleton(height: 14, width: 120),
            ],
          ),
        ),
      ],
    ),
  );
}
