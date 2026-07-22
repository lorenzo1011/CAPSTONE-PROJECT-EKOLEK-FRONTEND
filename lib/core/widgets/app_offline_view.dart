import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'app_error_view.dart';

class AppOfflineView extends StatelessWidget {
  const AppOfflineView({
    super.key,
    this.onRetry,
    this.compact = false,
    this.hasStaleData = false,
    this.lastUpdated,
  });

  final VoidCallback? onRetry;
  final bool compact;
  final bool hasStaleData;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final freshness = lastUpdated == null
        ? ''
        : ' Last updated ${MaterialLocalizations.of(context).formatShortDate(lastUpdated!)}.';
    final message = hasStaleData
        ? 'Showing previously loaded information. Some actions are unavailable until you reconnect.$freshness'
        : 'Check your network connection and try again.';
    final view = AppErrorView(
      icon: Icons.wifi_off_rounded,
      title: 'You appear to be offline',
      message: message,
      retryLabel: onRetry == null ? null : 'Try again',
      onRetry: onRetry,
      compact: compact,
    );
    if (!compact) return view;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: view,
    );
  }
}
