import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/achievements_providers.dart';
import '../models/badge_status.dart';
import '../providers/achievements_state.dart';
import '../widgets/achievement_gallery_skeleton.dart';
import '../widgets/badge_card.dart';

enum _Filter { all, unlocked, inProgress, locked }

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});
  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  _Filter filter = _Filter.all;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(achievementsControllerProvider).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementsStateProvider),
        controller = ref.read(achievementsControllerProvider);
    if (state.badges.isEmpty &&
        {
          AchievementsPhase.initial,
          AchievementsPhase.loading,
        }.contains(state.phase)) {
      return const Scaffold(
        appBar: _AppBar(),
        body: AchievementGallerySkeleton(),
      );
    }
    if (state.badges.isEmpty && state.phase == AchievementsPhase.offline) {
      return Scaffold(
        appBar: const _AppBar(),
        body: AppOfflineView(onRetry: controller.load),
      );
    }
    if (state.badges.isEmpty && state.phase == AchievementsPhase.failure) {
      return Scaffold(
        appBar: const _AppBar(),
        body: AppErrorView(
          title: 'Achievements unavailable',
          message: state.message!,
          onRetry: controller.load,
        ),
      );
    }
    final visible = state.badges
        .where(
          (badge) => switch (filter) {
            _Filter.unlocked => badge.isUnlocked,
            _Filter.inProgress => badge.status == BadgeStatus.inProgress,
            _Filter.locked => badge.status == BadgeStatus.locked,
            _ => true,
          },
        )
        .toList(growable: false);
    return Scaffold(
      appBar: const _AppBar(),
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
                    if (state.summary case final summary?)
                      Card(
                        child: Padding(
                          padding: AppSpacing.cardPadding,
                          child: Row(
                            children: [
                              Expanded(
                                child: _Metric(
                                  '${summary.totalUnlocked}',
                                  'Unlocked',
                                ),
                              ),
                              Expanded(
                                child: _Metric(
                                  '${summary.totalLocked}',
                                  'Locked',
                                ),
                              ),
                              Expanded(
                                child: _Metric(
                                  '${summary.completionPercentage.toStringAsFixed(0)}%',
                                  'Complete',
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
                            'Showing the last achievement information loaded on this device.',
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
                            value: _Filter.unlocked,
                            label: Text('Unlocked'),
                          ),
                          ButtonSegment(
                            value: _Filter.inProgress,
                            label: Text('In progress'),
                          ),
                          ButtonSegment(
                            value: _Filter.locked,
                            label: Text('Locked'),
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
                  icon: Icons.military_tech_rounded,
                  title: 'No achievements here',
                  message:
                      'Complete verified E-KOLEK activities to build your achievement gallery.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 900
                        ? 4
                        : width >= 600
                        ? 3
                        : 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: .72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= visible.length) {
                            controller.loadMore();
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final badge = visible[index];
                          return AchievementBadgeCard(
                            badge: badge,
                            onTap: () => context.push(
                              AppRoutes.badgeDetailPath(badge.id),
                            ),
                          );
                        },
                        childCount:
                            visible.length +
                            (state.hasNext && filter == _Filter.all ? 1 : 0),
                      ),
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

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: Theme.of(context).textTheme.headlineSmall),
      Text(label),
    ],
  );
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) =>
      AppBar(title: const Text('Achievements'));
}
