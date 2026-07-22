import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class LeaderboardScreenSkeleton extends StatelessWidget {
  const LeaderboardScreenSkeleton({super.key});
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: AppSpacing.screenPadding,
    itemCount: 8,
    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
    itemBuilder: (context, index) => AppSkeleton(height: index == 0 ? 120 : 72),
  );
}
