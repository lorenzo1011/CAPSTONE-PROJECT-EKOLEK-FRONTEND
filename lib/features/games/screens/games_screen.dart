import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../shared/providers/games_providers.dart';
import '../providers/games_state.dart';
import '../widgets/game_card.dart';
import '../widgets/games_screen_skeleton.dart';
import '../widgets/recent_game_activity.dart';

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
      title: 'Eco arcade',
      subtitle:
          'Quick challenges that reinforce sustainable choices and reward consistent learning.',
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
                if (state.dailyProgress != null)
                  AppCard(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    borderColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          size: 34,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.dailyProgress!.totalPointsEarned} points earned today',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${state.dailyProgress!.totalPlays} verified plays · Keep your momentum going',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
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
                const AppSectionHeader(
                  title: 'Recent activity',
                  subtitle: 'Your latest validated game sessions.',
                ),
                const SizedBox(height: AppSpacing.smMd),
                RecentGameActivity(attempts: state.recentAttempts),
                const SizedBox(height: AppSpacing.section),
                AppSectionHeader(
                  title: 'Choose a game',
                  subtitle: '${state.games.length} activities available now.',
                ),
                const SizedBox(height: AppSpacing.smMd),
              ],
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 430,
              mainAxisExtent: 210,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final game = state.games[index];
              return GameCard(
                game: game,
                onTap: () => context.push(AppRoutes.gameDetailPath(game.id)),
              );
            }, childCount: state.games.length),
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
