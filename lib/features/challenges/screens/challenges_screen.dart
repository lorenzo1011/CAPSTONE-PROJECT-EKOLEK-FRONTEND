import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/challenges_providers.dart';
import '../models/challenge_status.dart';
import '../providers/challenges_state.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenges_screen_skeleton.dart';

enum _Filter { all, active, upcoming, completed, history }

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});
  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  _Filter filter = _Filter.all;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(challengesControllerProvider).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengesStateProvider);
    final controller = ref.read(challengesControllerProvider);
    if (state.items.isEmpty &&
        (state.phase == ChallengesPhase.initial ||
            state.phase == ChallengesPhase.loading)) {
      return const AdaptivePageScaffold(
        title: 'Eco challenges',
        subtitle:
            'Join time-bound community goals and track verified progress.',
        body: ChallengesScreenSkeleton(),
      );
    }
    if (state.items.isEmpty && state.phase == ChallengesPhase.offline) {
      return AdaptivePageScaffold(
        title: 'Eco challenges',
        subtitle:
            'Join time-bound community goals and track verified progress.',
        body: AppOfflineView(onRetry: controller.load),
      );
    }
    if (state.items.isEmpty && state.phase == ChallengesPhase.failure) {
      return AdaptivePageScaffold(
        title: 'Eco challenges',
        subtitle:
            'Join time-bound community goals and track verified progress.',
        body: AppErrorView(
          title: 'Challenges unavailable',
          message: state.message!,
          retryLabel: 'Try again',
          onRetry: controller.load,
        ),
      );
    }
    final source = filter == _Filter.history ? state.history : state.items;
    final visible = source
        .where(
          (item) => switch (filter) {
            _Filter.active => item.status == ChallengeStatus.active,
            _Filter.upcoming => item.status == ChallengeStatus.upcoming,
            _Filter.completed => item.isCompleted,
            _ => true,
          },
        )
        .toList(growable: false);
    return AdaptivePageScaffold(
      title: 'Eco challenges',
      subtitle: 'Join time-bound community goals and track verified progress.',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isStale)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.cloud_off_rounded),
                          title: Text(
                            'Showing the last challenge information loaded on this device.',
                          ),
                        ),
                      ),
                    if (state.message != null)
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(state.message!),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<_Filter>(
                        segments: const [
                          ButtonSegment(value: _Filter.all, label: Text('All')),
                          ButtonSegment(
                            value: _Filter.active,
                            label: Text('Active'),
                          ),
                          ButtonSegment(
                            value: _Filter.upcoming,
                            label: Text('Upcoming'),
                          ),
                          ButtonSegment(
                            value: _Filter.completed,
                            label: Text('Completed'),
                          ),
                          ButtonSegment(
                            value: _Filter.history,
                            label: Text('My progress'),
                          ),
                        ],
                        selected: {filter},
                        onSelectionChanged: (value) =>
                            setState(() => filter = value.first),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.flag_outlined,
                  title: 'No matching eco challenges',
                  message: 'No challenge is currently available in this view.',
                ),
              )
            else
              SliverPadding(
                padding: AppSpacing.screenPadding,
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 520,
                    mainAxisExtent: 250,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (_, index) => ChallengeCard(
                    challenge: visible[index],
                    onTap: () => context.push(
                      AppRoutes.challengeDetailPath(visible[index].id),
                    ),
                  ),
                ),
              ),
            if (state.hasNext && filter == _Filter.all)
              SliverToBoxAdapter(
                child: Center(
                  child: TextButton.icon(
                    onPressed: state.phase == ChallengesPhase.loadingMore
                        ? null
                        : controller.loadMore,
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('Load more'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
