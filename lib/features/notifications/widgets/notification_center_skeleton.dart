import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_skeleton.dart';

class NotificationCenterSkeleton extends StatelessWidget {
  const NotificationCenterSkeleton({super.key});
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: AppSpacing.screenPadding,
    itemCount: 7,
    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
    itemBuilder: (context, index) => const AppSkeleton(height: 92),
  );
}
