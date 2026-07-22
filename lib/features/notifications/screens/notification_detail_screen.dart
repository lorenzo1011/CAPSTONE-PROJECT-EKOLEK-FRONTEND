import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/notifications_providers.dart';
import '../models/notification_action.dart';

class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});
  final int notificationId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Notification')),
    body: ref
        .watch(notificationDetailProvider(notificationId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => AppErrorView(
            title: 'Notification unavailable',
            message: 'This notification is no longer available.',
            onRetry: () =>
                ref.invalidate(notificationDetailProvider(notificationId)),
          ),
          data: (item) => SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(item.type.icon, size: 64),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Chip(
                      avatar: Icon(item.type.icon),
                      label: Text(item.type.label),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      item.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(AppFormatters.dateTime(item.createdAt)),
                    if (item.action.hasValidEntity) ...[
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton.icon(
                        onPressed: () => _open(context, item.action),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('View related update'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
  );
  void _open(BuildContext context, NotificationAction action) {
    final id = action.entityId;
    final path = switch (action.type) {
      NotificationActionType.collectionEvent when id != null =>
        AppRoutes.eventDetailPath('collection', id),
      NotificationActionType.rewardEvent when id != null =>
        AppRoutes.eventDetailPath('rewardDistribution', id),
      NotificationActionType.reward when id != null =>
        AppRoutes.rewardDetailPath(id),
      NotificationActionType.redemption when id != null =>
        AppRoutes.redemptionDetailPath(id),
      NotificationActionType.learningVideo when id != null =>
        AppRoutes.learningVideoPath(id),
      NotificationActionType.game when id != null => AppRoutes.gameDetailPath(
        id,
      ),
      NotificationActionType.challenge when id != null =>
        AppRoutes.challengeDetailPath(id),
      NotificationActionType.achievement when id != null =>
        AppRoutes.badgeDetailPath(id),
      NotificationActionType.leaderboard => AppRoutes.leaderboardPath,
      NotificationActionType.wallet => AppRoutes.walletActivityPath,
      _ => null,
    };
    if (path != null) context.push(path);
  }
}
