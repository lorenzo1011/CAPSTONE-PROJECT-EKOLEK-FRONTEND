import 'package:flutter/material.dart';

import 'app_empty_state.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.backLabel,
    this.onBack,
    this.compact = false,
  });

  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? backLabel;
  final VoidCallback? onBack;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final view = AppEmptyState(
      icon: icon,
      title: title,
      message: message,
      actionLabel: retryLabel,
      onAction: onRetry,
      secondaryActionLabel: backLabel,
      onSecondaryAction: onBack,
    );
    return compact
        ? ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 180),
            child: view,
          )
        : view;
  }
}
