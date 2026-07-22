import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class QuizTakingSkeleton extends StatelessWidget {
  const QuizTakingSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton(height: 12),
        SizedBox(height: 32),
        AppSkeleton(height: 28),
        SizedBox(height: 24),
        AppSkeleton(height: 64),
        SizedBox(height: 12),
        AppSkeleton(height: 64),
        SizedBox(height: 12),
        AppSkeleton(height: 64),
      ],
    ),
  );
}
