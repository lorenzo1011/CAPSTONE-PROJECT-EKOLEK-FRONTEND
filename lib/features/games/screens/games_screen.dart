import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
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
      title: 'Games',
      subtitle: 'Play, learn, and earn responsibly',
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
                  const ListTile(
                    leading: Icon(Icons.cloud_off_rounded),
                    title: Text('Showing previously loaded game information.'),
                  ),
                if (state.dailyProgress != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.today_rounded),
                      title: Text(
                        '${state.dailyProgress!.totalPointsEarned} game points earned today',
                      ),
                      subtitle: Text(
                        '${state.dailyProgress!.totalPlays} verified plays',
                      ),
                    ),
                  ),
                if (state.dailyMessage != null)
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(state.dailyMessage!),
                  ),
                RecentGameActivity(attempts: state.recentAttempts),
                const SizedBox(height: AppSpacing.md),
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
