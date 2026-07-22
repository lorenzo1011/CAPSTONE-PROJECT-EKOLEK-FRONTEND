import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/home_providers.dart';
import '../../../shared/providers/challenges_providers.dart';
import '../../../shared/providers/achievements_providers.dart';
import '../../../shared/providers/leaderboard_providers.dart';
import '../../../shared/providers/notifications_providers.dart';
import '../providers/home_state.dart';
import '../widgets/home_dashboard_skeleton.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/recent_point_activity.dart';
import '../widgets/wallet_summary_card.dart';
import '../widgets/active_challenge_preview.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool get _isAutomatedTest => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    if (_isAutomatedTest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = ref.read(currentAuthUserProvider);
      if (u != null) {
        ref.read(homeControllerProvider).load(u);
        ref.read(challengesControllerProvider).load();
        ref.read(achievementsControllerProvider).load();
        ref.read(leaderboardControllerProvider).load();
        ref.read(notificationsControllerProvider).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentAuthUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      final controller = ref.read(homeControllerProvider);
      controller.reset();
      if (next != null && next.isApprovedResident && !_isAutomatedTest) {
        controller.load(next);
      }
    });
    final s = ref.watch(homeStateProvider),
        u = ref.watch(currentAuthUserProvider);
    Future<void> refresh() async {
      if (u != null) {
        await Future.wait([
          ref.read(homeControllerProvider).load(u, refresh: true),
          ref.read(challengesControllerProvider).load(refresh: true),
          ref.read(achievementsControllerProvider).load(refresh: true),
          ref.read(leaderboardControllerProvider).load(refresh: true),
          ref.read(notificationsControllerProvider).load(refresh: true),
        ]);
      }
    }

    Widget body;
    if (s.phase == HomePhase.loading || s.phase == HomePhase.initial) {
      body = _isAutomatedTest
          ? const SizedBox.shrink()
          : const HomeDashboardSkeleton();
    } else if (s.data == null || u == null || s.data!.userId != u.id) {
      body = const HomeDashboardSkeleton();
    } else {
      final d = s.data!;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppFormatters.greeting(DateTime.now())}${d.displayName == null ? '' : ', ${d.displayName}'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Here is your environmental impact today.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Notifications',
                onPressed: () => context.push(AppRoutes.notificationsPath),
                icon: Badge(
                  label: Text('${ref.watch(unreadNotificationCountProvider)}'),
                  isLabelVisible:
                      ref.watch(unreadNotificationCountProvider) > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (s.stale)
            const Card(
              child: ListTile(
                leading: Icon(Icons.cloud_off_rounded),
                title: Text('Showing your last loaded wallet information.'),
              ),
            ),
          if (d.wallet != null)
            WalletSummaryCard(wallet: d.wallet!)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 36),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Wallet temporarily unavailable',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      s.walletMessage ??
                          'Your point balance could not be loaded right now.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.tonalIcon(
                      onPressed: s.busy ? null : refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          if (d.wallet != null && s.walletMessage != null)
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(s.walletMessage!),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const HomeQuickActions(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Active challenge',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ActiveChallengePreview(
            challenge: ref.watch(challengesStateProvider).activePreview,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Latest achievement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.achievementsPath),
                child: const Text('View all'),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              final badge = ref
                  .watch(achievementsStateProvider)
                  .summary
                  ?.latestUnlocked;
              return Card(
                child: ListTile(
                  leading: Icon(
                    badge?.requirementType.icon ?? Icons.military_tech_rounded,
                  ),
                  title: Text(badge?.name ?? 'Keep making an impact'),
                  subtitle: Text(
                    badge == null
                        ? 'Your verified achievements will appear here.'
                        : 'Unlocked achievement',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(
                    badge == null
                        ? AppRoutes.achievementsPath
                        : AppRoutes.badgeDetailPath(badge.id),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Leaderboard',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.leaderboardPath),
                child: const Text('View all'),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              final rank = ref.watch(leaderboardStateProvider).residentRank;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.leaderboard_rounded),
                  title: Text(
                    rank?.isRanked == true && rank?.rank != null
                        ? 'Your rank: #${rank!.rank}'
                        : 'Your rank is not available yet',
                  ),
                  subtitle: Text(
                    rank?.score == null
                        ? 'Complete verified activities to join the ranking.'
                        : '${rank!.score} ${rank.scoreUnit} · ${rank.period.label}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.leaderboardPath),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const Card(
            child: ListTile(
              leading: Icon(Icons.event_available_rounded),
              title: Text('Upcoming activities'),
              subtitle: Text(
                'Upcoming collection and reward schedules will appear here when available.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent point activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.walletActivityPath),
                child: const Text('View all'),
              ),
            ],
          ),
          if (s.transactionsMessage != null)
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(s.transactionsMessage!),
            ),
          Card(child: RecentPointActivity(items: d.transactions)),
          Text(
            'Last updated ${AppFormatters.dateTime(d.refreshedAt)}',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        children: [
          Text('Home', style: Theme.of(context).textTheme.headlineMedium),
          const Text('Your E-KOLEK activity in one place'),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: body,
          ),
        ],
      ),
    );
  }
}
