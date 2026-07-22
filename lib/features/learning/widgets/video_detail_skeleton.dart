import 'package:flutter/material.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../app/theme/app_spacing.dart';

class VideoDetailSkeleton extends StatelessWidget {
  const VideoDetailSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: AppSkeleton(height: 200)),
        SizedBox(height: 24),
        AppSkeleton(height: 28),
        SizedBox(height: 16),
        AppSkeleton(height: 16),
        SizedBox(height: 8),
        AppSkeleton(height: 16),
      ],
    ),
  );
}
