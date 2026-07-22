import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class GameDetailSkeleton extends StatelessWidget {
  const GameDetailSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton(height: 180),
        SizedBox(height: 24),
        AppSkeleton(height: 30),
        SizedBox(height: 12),
        AppSkeleton(height: 16),
        SizedBox(height: 8),
        AppSkeleton(height: 16),
      ],
    ),
  );
}
