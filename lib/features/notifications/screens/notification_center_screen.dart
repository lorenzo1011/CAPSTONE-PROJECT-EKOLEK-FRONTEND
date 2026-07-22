import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/notifications_providers.dart';
import '../providers/notifications_state.dart';
import '../widgets/notification_center_skeleton.dart';
import '../widgets/notification_tile.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});
  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(notificationsControllerProvider).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsStateProvider),
        controller = ref.read(notificationsControllerProvider);
    if (state.items.isEmpty &&
        {
          NotificationsPhase.initial,
          NotificationsPhase.loading,
        }.contains(state.phase)) {
      return const Scaffold(
        appBar: _NotificationAppBar(),
        body: NotificationCenterSkeleton(),
      );
    }
    if (state.items.isEmpty && state.phase == NotificationsPhase.offline) {
      return Scaffold(
        appBar: const _NotificationAppBar(),
        body: AppOfflineView(onRetry: controller.load),
      );
    }
    if (state.items.isEmpty && state.phase == NotificationsPhase.failure) {
      return Scaffold(
        appBar: const _NotificationAppBar(),
        body: AppErrorView(
          title: 'Notifications unavailable',
          message: state.message!,
          onRetry: controller.load,
        ),
      );
    }
    return Scaffold(
      appBar: _NotificationAppBar(
        unreadCount: state.unreadCount,
        busy: state.phase == NotificationsPhase.updating,
        onMarkAll: controller.markAllRead,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.load(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.notifications_paused_outlined),
                        title: Text('Push notifications are not configured'),
                        subtitle: Text(
                          'You can still receive verified updates in this Notification Center.',
                        ),
                      ),
                    ),
                    if (state.isStale)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.cloud_off_rounded),
                          title: Text(
                            'Showing the last notification information loaded on this device.',
                          ),
                        ),
                      ),
                    if (state.message != null)
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(state.message!),
                      ),
                  ],
                ),
              ),
            ),
            if (state.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications',
                  message:
                      'Resident updates and announcements will appear here.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList.builder(
                  itemCount: state.items.length + (state.hasNext ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      controller.loadMore();
                      return const Center(child: CircularProgressIndicator());
                    }
                    final item = state.items[index];
                    return AppNotificationTile(
                      notification: item,
                      onTap: () async {
                        if (item.isUnread) {
                          await controller.markRead(item.id);
                        }
                        if (context.mounted) {
                          context.push(
                            AppRoutes.notificationDetailPath(item.id),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _NotificationAppBar({
    this.unreadCount = 0,
    this.busy = false,
    this.onMarkAll,
  });
  final int unreadCount;
  final bool busy;
  final VoidCallback? onMarkAll;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(
      unreadCount > 0 ? 'Notifications ($unreadCount)' : 'Notifications',
    ),
    actions: [
      TextButton(
        onPressed: unreadCount == 0 || busy ? null : onMarkAll,
        child: Text(busy ? 'Updating…' : 'Mark all read'),
      ),
    ],
  );
}
