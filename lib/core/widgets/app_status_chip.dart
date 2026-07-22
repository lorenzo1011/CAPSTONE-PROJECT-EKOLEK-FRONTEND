import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum AppStatusTone { neutral, success, warning, error, info }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
  });

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      AppStatusTone.success => AppColors.success,
      AppStatusTone.warning => AppColors.warning,
      AppStatusTone.error => AppColors.error,
      AppStatusTone.info => AppColors.info,
      AppStatusTone.neutral => AppColors.textSecondary,
    };
    final resolvedIcon =
        icon ??
        switch (tone) {
          AppStatusTone.success => Icons.check_circle_outline_rounded,
          AppStatusTone.warning => Icons.warning_amber_rounded,
          AppStatusTone.error => Icons.error_outline_rounded,
          AppStatusTone.info => Icons.info_outline_rounded,
          AppStatusTone.neutral => Icons.circle_outlined,
        };
    return Semantics(
      label: 'Status: $label',
      child: Chip(
        avatar: Icon(resolvedIcon, size: 18, color: color),
        label: Text(label),
        side: BorderSide(color: color),
      ),
    );
  }
}
