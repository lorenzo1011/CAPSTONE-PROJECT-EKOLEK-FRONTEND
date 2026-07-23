import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../shared/providers/games_providers.dart';
import '../providers/games_state.dart';
import '../models/daily_game_progress.dart';
import '../widgets/game_card.dart';
import '../widgets/games_screen_skeleton.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});
  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(gamesControllerProvider);
      if (controller.state.phase == GamesPhase.initial) controller.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gamesControllerProvider);
    final state = controller.state;
    return AdaptivePageScaffold(
      title: 'Games',
      subtitle:
          'Play, learn, and earn!\nFun challenges that make a difference.',
      actions: [
        IconButton(
          tooltip: 'Games',
          onPressed: () {},
          icon: const Icon(Icons.sports_esports_outlined),
        ),
      ],
      body: _body(controller, state),
    );
  }

  Widget _body(dynamic controller, GamesState state) {
    if (state.phase == GamesPhase.loading && state.games.isEmpty) {
      return const GamesScreenSkeleton();
    }
    if (state.phase == GamesPhase.offline && state.games.isEmpty) {
      return AppOfflineView(onRetry: controller.load);
    }
    if (state.phase == GamesPhase.failure && state.games.isEmpty) {
      return AppErrorView(
        title: 'Games unavailable',
        message:
            state.message ?? 'Games could not be loaded. Please try again.',
        retryLabel: 'Try again',
        onRetry: controller.load,
      );
    }
    if (state.games.isEmpty) {
      return const AppEmptyState(
        icon: Icons.sports_esports_rounded,
        title: 'No games available',
        message:
            'Published eco-games will appear here when they become available.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => controller.load(refresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (state.isStale)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppCard(
                      child: const ListTile(
                        leading: Icon(Icons.cloud_off_rounded),
                        title: Text(
                          'Showing previously loaded game information.',
                        ),
                      ),
                    ),
                  ),
                _GamesHero(
                  progress: state.dailyProgress,
                  onPlay: () {
                    final game = state.games.first;
                    context.push(AppRoutes.gameDetailPath(game.id));
                  },
                ),
                if (state.dailyMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(state.dailyMessage!),
                    ),
                  ),
                const SizedBox(height: AppSpacing.section),
                const _AchievementsStrip(),
                const SizedBox(height: AppSpacing.section),
                AppSectionHeader(title: 'All Games', actionLabel: 'See all'),
                const SizedBox(height: AppSpacing.smMd),
              ],
            ),
          ),
          SliverList.separated(
            itemCount: state.games.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final game = state.games[index];
              return GameCard(
                game: game,
                onTap: () => context.push(AppRoutes.gameDetailPath(game.id)),
              );
            },
          ),
          if (state.hasNext)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: FilledButton.tonal(
                    onPressed: controller.loadMore,
                    child: const Text('Load more'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementsStrip extends StatelessWidget {
  const _AchievementsStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.eco_rounded, 'Eco\nStarter'),
      (Icons.recycling_rounded, 'Segregation\nPro'),
      (Icons.energy_savings_leaf_rounded, 'Green\nStreak'),
      (Icons.groups_rounded, 'Community\nHero'),
      (Icons.emoji_events_rounded, 'Eco\nChampion'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Achievements',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              'See all',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.smMd),
        Row(
          children: [
            for (final item in items)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: 2,
                        ),
                      ),
                      child: Icon(item.$1, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _GamesHero extends StatelessWidget {
  const _GamesHero({required this.onPlay, required this.progress});

  final VoidCallback onPlay;
  final DailyGameProgress? progress;

  @override
  Widget build(BuildContext context) => Container(
    height: 280,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFFDFF5FF),
      borderRadius: AppRadius.extraLargeBorderRadius,
      border: Border.all(color: const Color(0xFFCDE9F6)),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/bg_eco_park_city.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 82,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF32B83F), Color(0xFF07873B)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.emoji_events_rounded,
                    value: '${progress?.totalPointsEarned ?? 0}',
                    label: 'Points Today',
                  ),
                ),
                const SizedBox(
                  height: 48,
                  child: VerticalDivider(color: Color(0x66FFFFFF)),
                ),
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.sports_esports_rounded,
                    value: '${progress?.totalPlays ?? 0}',
                    label: 'Games Played',
                  ),
                ),
                const SizedBox(
                  height: 48,
                  child: VerticalDivider(color: Color(0x66FFFFFF)),
                ),
                const Expanded(
                  child: _HeroMetric(
                    icon: Icons.energy_savings_leaf_rounded,
                    value: '—',
                    label: 'Day Streak',
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 62,
          width: 220,
          height: 220,
          child: Image.asset(
            'assets/images/onboarding/games_eco_bird_runner.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned.fill(
          child: Material(
            color: AppColors.transparent,
            child: InkWell(onTap: onPlay),
          ),
        ),
      ],
    ),
  );
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: AppColors.white, size: 21),
      Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.white, fontSize: 9),
      ),
    ],
  );
}
