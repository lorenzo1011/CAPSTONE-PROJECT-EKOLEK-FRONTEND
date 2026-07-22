import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/leaderboard_providers.dart';
import '../models/leaderboard_scope.dart';
import '../providers/leaderboard_state.dart';
import '../widgets/leaderboard_screen_skeleton.dart';
import '../widgets/ranking_row.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(leaderboardControllerProvider).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardStateProvider),
        controller = ref.read(leaderboardControllerProvider);
    if (!state.hasData &&
        {
          LeaderboardPhase.initial,
          LeaderboardPhase.loading,
        }.contains(state.phase)) {
      return const Scaffold(
        appBar: _LeaderboardAppBar(),
        body: LeaderboardScreenSkeleton(),
      );
    }
    if (!state.hasData && state.phase == LeaderboardPhase.offline) {
      return Scaffold(
        appBar: const _LeaderboardAppBar(),
        body: AppOfflineView(onRetry: controller.load),
      );
    }
    if (!state.hasData && state.phase == LeaderboardPhase.failure) {
      return Scaffold(
        appBar: const _LeaderboardAppBar(),
        body: AppErrorView(
          title: 'Leaderboard unavailable',
          message: state.message!,
          onRetry: controller.load,
        ),
      );
    }
    final residentScope = state.scope == LeaderboardScope.barangayResidents;
    final page = residentScope ? state.residentPage : state.barangayPage;
    final rank = residentScope ? state.residentRank : state.barangayRank;
    final itemCount = residentScope
        ? state.residentPage?.items.length ?? 0
        : state.barangayPage?.items.length ?? 0;
    return Scaffold(
      appBar: const _LeaderboardAppBar(),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<LeaderboardScope>(
                      segments: const [
                        ButtonSegment(
                          value: LeaderboardScope.barangayResidents,
                          icon: Icon(Icons.people_outline_rounded),
                          label: Text('Residents'),
                        ),
                        ButtonSegment(
                          value: LeaderboardScope.cityBarangays,
                          icon: Icon(Icons.location_city_rounded),
                          label: Text('Barangays'),
                        ),
                      ],
                      selected: {state.scope},
                      onSelectionChanged: (value) =>
                          controller.selectScope(value.first),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (rank != null)
                      Card(
                        child: Padding(
                          padding: AppSpacing.cardPadding,
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events_outlined, size: 40),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      residentScope
                                          ? 'Your resident rank'
                                          : 'Your barangay rank',
                                    ),
                                    Text(
                                      rank.isRanked && rank.rank != null
                                          ? '#${rank.rank}'
                                          : 'Unranked',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    Text(
                                      rank.score == null
                                          ? 'Score unavailable'
                                          : '${rank.score} ${rank.scoreUnit} · ${rank.period.label}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (state.isStale)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.cloud_off_rounded),
                          title: Text(
                            'Showing the last leaderboard information loaded on this device.',
                          ),
                        ),
                      ),
                    if (state.message != null)
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(state.message!),
                      ),
                    Text(
                      page?.scopeLabel ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${page?.scoreLabel ?? 'Verified score'} · ${page?.period.label ?? ''}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
            if (itemCount == 0)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.leaderboard_outlined,
                  title: 'No rankings yet',
                  message:
                      'Verified rankings will appear after eligible activity is recorded.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList.builder(
                  itemCount: itemCount + (state.hasNext ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= itemCount) {
                      controller.loadMore();
                      return const Padding(
                        padding: AppSpacing.cardPadding,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (residentScope) {
                      final item = state.residentPage!.items[index];
                      return RankingRow(
                        rank: item.rank,
                        name: item.displayName,
                        score: item.score,
                        unit: item.scoreUnit,
                        highlighted: item.isCurrentUser,
                        isTied: item.isTied,
                      );
                    }
                    final item = state.barangayPage!.items[index];
                    return RankingRow(
                      rank: item.rank,
                      name: item.barangayName,
                      score: item.score,
                      unit: item.scoreUnit,
                      highlighted: item.isCurrentBarangay,
                      isTied: item.isTied,
                      subtitle:
                          '${AppFormatters.points(item.eligibleResidentCount)} eligible residents',
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Text(
                  page?.updatedAt == null
                      ? ''
                      : 'Updated ${AppFormatters.dateTime(page!.updatedAt)}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _LeaderboardAppBar();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) =>
      AppBar(title: const Text('Leaderboard'));
}
