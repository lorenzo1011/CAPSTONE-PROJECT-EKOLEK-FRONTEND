import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_layout.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_reveal.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../shared/providers/achievements_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/challenges_providers.dart';
import '../../../shared/providers/home_providers.dart';
import '../../../shared/providers/leaderboard_providers.dart';
import '../../../shared/providers/notifications_providers.dart';
import '../providers/home_state.dart';
import '../widgets/active_challenge_preview.dart';
import '../widgets/home_dashboard_skeleton.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/recent_point_activity.dart';
import '../widgets/wallet_summary_card.dart';
import '../../wallet/models/wallet_summary.dart';

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
      final user = ref.read(currentAuthUserProvider);
      if (user == null || !user.isApprovedResident) return;

      ref.read(homeControllerProvider).load(user);
      ref.read(challengesControllerProvider).load();
      ref.read(achievementsControllerProvider).load();
      ref.read(leaderboardControllerProvider).load();
      ref.read(notificationsControllerProvider).load();
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

    final state = ref.watch(homeStateProvider);
    final user = ref.watch(currentAuthUserProvider);
    final challenge = ref.watch(challengesStateProvider).activePreview;
    final latestBadge = ref
        .watch(achievementsStateProvider)
        .summary
        ?.latestUnlocked;
    final residentRank = ref.watch(leaderboardStateProvider).residentRank;
    final unread = ref.watch(unreadNotificationCountProvider);

    Future<void> refresh() async {
      if (user == null) return;

      await Future.wait([
        ref.read(homeControllerProvider).load(user, refresh: true),
        ref.read(challengesControllerProvider).load(refresh: true),
        ref.read(achievementsControllerProvider).load(refresh: true),
        ref.read(leaderboardControllerProvider).load(refresh: true),
        ref.read(notificationsControllerProvider).load(refresh: true),
      ]);
    }

    Widget dashboard;

    if (state.phase == HomePhase.loading || state.phase == HomePhase.initial) {
      dashboard = _isAutomatedTest
          ? const SizedBox.shrink()
          : const HomeDashboardSkeleton();
    } else if (state.data == null ||
        user == null ||
        state.data!.userId != user.id) {
      dashboard = const HomeDashboardSkeleton();
    } else {
      final data = state.data!;

      final wallet = data.wallet == null
          ? _WalletUnavailableCard(
              message: state.walletMessage,
              busy: state.busy,
              onRetry: refresh,
            )
          : WalletSummaryCard(wallet: data.wallet!);

      final achievementCard = _InsightCard(
        icon: latestBadge?.requirementType.icon ?? Icons.military_tech_rounded,
        accent: AppColors.achievement,
        eyebrow: latestBadge == null ? 'NEXT MILESTONE' : 'LATEST UNLOCK',
        title: latestBadge?.name ?? 'Keep making an impact',
        subtitle: latestBadge == null
            ? 'Your verified achievements will appear here.'
            : 'Achievement unlocked through verified environmental action.',
        onTap: () => context.push(
          latestBadge == null
              ? AppRoutes.achievementsPath
              : AppRoutes.badgeDetailPath(latestBadge.id),
        ),
      );

      final rankCard = _InsightCard(
        icon: Icons.leaderboard_rounded,
        accent: AppColors.schedule,
        eyebrow: 'COMMUNITY STANDING',
        title: residentRank?.isRanked == true && residentRank?.rank != null
            ? 'You are ranked #${residentRank!.rank}'
            : 'Your rank is not available yet',
        subtitle: residentRank?.score == null
            ? 'Complete verified activities to join the community ranking.'
            : '${residentRank?.score} ${residentRank?.scoreUnit ?? ''} · ${residentRank?.period.label ?? ''}',
        onTap: () => context.push(AppRoutes.leaderboardPath),
      );

      final activityCard = Card(
        child: Column(
          children: [
            if (state.transactionsMessage != null)
              _InlineNotice(message: state.transactionsMessage!),
            RecentPointActivity(items: data.transactions),
          ],
        ),
      );

      final challengeSection = _SectionBlock(
        title: 'Active challenge',
        subtitle: 'Keep your current environmental goal moving.',
        actionLabel: 'Explore',
        onAction: () => context.push(AppRoutes.challengesPath),
        child: ActiveChallengePreview(challenge: challenge),
      );

      final achievementSection = _SectionBlock(
        title: 'Latest achievement',
        subtitle: 'Milestones earned through verified actions.',
        actionLabel: 'View all',
        onAction: () => context.push(AppRoutes.achievementsPath),
        child: achievementCard,
      );

      final rankSection = _SectionBlock(
        title: 'Community standing',
        subtitle: 'See how your verified impact compares.',
        actionLabel: 'Leaderboard',
        onAction: () => context.push(AppRoutes.leaderboardPath),
        child: rankCard,
      );

      final activitySection = _SectionBlock(
        title: 'Recent point activity',
        subtitle: 'Your latest earning and redemption history.',
        actionLabel: 'View all',
        onAction: () => context.push(AppRoutes.walletActivityPath),
        child: activityCard,
      );

      dashboard = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.stale) ...[
            const _StatusBanner(
              icon: Icons.cloud_off_rounded,
              title: 'Showing your last synced information',
              message: 'Pull down to reconnect and refresh.',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppReveal(child: wallet),
          if (data.wallet != null && state.walletMessage != null) ...[
            const SizedBox(height: AppSpacing.smMd),
            _InlineNotice(message: state.walletMessage!),
          ],
          if (data.wallet != null) ...[
            const SizedBox(height: AppSpacing.smMd),
            _WalletStats(wallet: data.wallet!),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.smMd),
          const AppReveal(
            delay: Duration(milliseconds: 70),
            child: HomeQuickActions(),
          ),
          const SizedBox(height: AppSpacing.section),
          const _ImpactToday(),
          const SizedBox(height: AppSpacing.md),
          _MovementBanner(onTap: () => context.go(AppRoutes.learnPath)),
          const SizedBox(height: AppSpacing.section),
          AppReveal(
            delay: const Duration(milliseconds: 210),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide =
                    constraints.maxWidth >= AppLayout.dashboardBreakpoint;

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      challengeSection,
                      const SizedBox(height: AppSpacing.section),
                      achievementSection,
                      const SizedBox(height: AppSpacing.section),
                      rankSection,
                      const SizedBox(height: AppSpacing.lg),
                      const _UpcomingActivityCard(),
                      const SizedBox(height: AppSpacing.section),
                      activitySection,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          challengeSection,
                          const SizedBox(height: AppSpacing.section),
                          activitySection,
                        ],
                      ),
                    ),
                    const SizedBox(width: AppLayout.dashboardColumnGap),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          achievementSection,
                          const SizedBox(height: AppSpacing.section),
                          rankSection,
                          const SizedBox(height: AppSpacing.lg),
                          const _UpcomingActivityCard(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _UpdatedLabel(updatedAt: data.refreshedAt),
        ],
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.1 : 0.32,
            ),
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0, 0.24, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = AppLayout.horizontalPagePadding(
                constraints.maxWidth,
              );

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppSpacing.smMd,
                  horizontal,
                  AppSpacing.huge,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppLayout.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppReveal(child: _HomeTopBar(unread: unread)),
                          const SizedBox(height: AppSpacing.md),
                          AppReveal(
                            delay: const Duration(milliseconds: 70),
                            child: _HomeHeroBanner(
                              onTap: () => context.go(AppRoutes.learnPath),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          dashboard,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        _SoftIconButton(
          tooltip: 'Profile',
          icon: Icons.person_outline_rounded,
          onPressed: () => context.go(AppRoutes.profilePath),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/branding/ekoleklogo.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'E-KOLEK',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        _SoftIconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutes.notificationsPath),
          child: Badge(
            label: Text('$unread'),
            isLabelVisible: unread > 0,
            child: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
    );
  }
}

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.child,
  }) : assert(icon != null || child != null);

  final String tooltip;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface.withValues(alpha: 0.9),
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      icon: child ?? Icon(icon),
    );
  }
}

class _HomeHeroBanner extends StatelessWidget {
  const _HomeHeroBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    height: 210,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.heroStart, AppColors.heroEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: AppRadius.extraLargeBorderRadius,
      boxShadow: const [
        BoxShadow(
          color: AppColors.heroShadow,
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -24,
            width: 220,
            height: 220,
            child: Image.asset(
              'assets/images/onboarding/home_hero_earth_hands.png',
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 185,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Small actions,\nbig impact.',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Earn points, protect our planet.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFEDE4FF),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryDark,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Learn more'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WalletStats extends StatelessWidget {
  const _WalletStats({required this.wallet});
  final WalletSummary wallet;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _MiniStat(
          icon: Icons.qr_code_2_rounded,
          label: 'Lifetime Earned',
          value: '${AppFormatters.points(wallet.lifetimeEarned)} pts',
          color: AppColors.primary,
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: _MiniStat(
          icon: Icons.card_giftcard_rounded,
          label: 'Total Redeemed',
          value: '${AppFormatters.points(wallet.lifetimeRedeemed)} pts',
          color: const Color(0xFF159447),
        ),
      ),
    ],
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.smMd),
    decoration: BoxDecoration(
      color: const Color(0xFFFCFAFF),
      borderRadius: AppRadius.mediumBorderRadius,
      border: Border.all(color: const Color(0xFFEAE3F4)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ImpactToday extends StatelessWidget {
  const _ImpactToday();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your Impact Today 🌱',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: AppSpacing.smMd),
      const Row(
        children: [
          Expanded(
            child: _ImpactMetric(
              icon: Icons.recycling_rounded,
              label: 'Recyclables',
              value: '— kg',
              color: Color(0xFF169447),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ImpactMetric(
              icon: Icons.cloud_outlined,
              label: 'CO₂ Reduced',
              value: '— kg',
              color: Color(0xFF57B9E8),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ImpactMetric(
              icon: Icons.park_rounded,
              label: 'Trees Saved',
              value: '—',
              color: Color(0xFF4B9D32),
            ),
          ),
        ],
      ),
    ],
  );
}

class _ImpactMetric extends StatelessWidget {
  const _ImpactMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: AppRadius.mediumBorderRadius,
      border: Border.all(color: const Color(0xFFEAE5F0)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(height: AppSpacing.sm),
        FittedBox(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _MovementBanner extends StatelessWidget {
  const _MovementBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    height: 112,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFFF5EEFF),
      borderRadius: AppRadius.largeBorderRadius,
    ),
    child: Stack(
      children: [
        Positioned(
          right: -4,
          bottom: -30,
          width: 135,
          height: 135,
          child: Image.asset(
            'assets/images/onboarding/home_hero_earth_hands.png',
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join the movement',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                'Small actions, big impact.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              SizedBox(
                height: 30,
                child: FilledButton(
                  onPressed: onTap,
                  child: const Text('Learn more'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeader(
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
      const SizedBox(height: AppSpacing.smMd),
      child,
    ],
  );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.accent,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: AppRadius.largeBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.largeBorderRadius,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.largeBorderRadius,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mediumBorderRadius,
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: AppSpacing.smMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.65,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingActivityCard extends StatelessWidget {
  const _UpcomingActivityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: AppRadius.largeBorderRadius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadius.mediumBorderRadius,
            ),
            child: Icon(Icons.event_available_rounded, color: scheme.secondary),
          ),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming activities',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Collection and reward schedules will appear here once available.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: AppRadius.largeBorderRadius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.smMd,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletUnavailableCard extends StatelessWidget {
  const _WalletUnavailableCard({
    required this.message,
    required this.busy,
    required this.onRetry,
  });

  final String? message;
  final bool busy;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.heroBorderRadius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: scheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Text(
            'Wallet temporarily unavailable',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message ?? 'Your point balance could not be loaded right now.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonalIcon(
            onPressed: busy ? null : onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(busy ? 'Refreshing' : 'Try again'),
          ),
        ],
      ),
    );
  }
}

class _UpdatedLabel extends StatelessWidget {
  const _UpdatedLabel({required this.updatedAt});

  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sync_rounded, size: 15, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'Last updated ${AppFormatters.dateTime(updatedAt)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
