import 'package:flutter/material.dart';
import '../../../core/widgets/app_skeleton.dart';

class DigitalIdSkeleton extends StatelessWidget {
  const DigitalIdSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      AppSkeleton(height: 220, borderRadius: 20),
      SizedBox(height: 16),
      AppSkeleton(height: 330, borderRadius: 16),
      SizedBox(height: 16),
      AppSkeleton(height: 150, borderRadius: 16),
    ],
  );
}
