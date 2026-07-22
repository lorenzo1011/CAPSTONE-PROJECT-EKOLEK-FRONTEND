import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../shared/providers/learning_providers.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../providers/learning_state.dart';
import '../widgets/learning_screen_skeleton.dart';
import '../widgets/learning_video_card.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});
  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(learningControllerProvider);
      if (controller.state.status == LearningStatus.initial) controller.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(learningControllerProvider);
    final state = controller.state;
    return AdaptivePageScaffold(
      title: 'Learning hub',
      subtitle:
          'Practical lessons designed to turn everyday choices into lasting environmental habits.',
      body: _body(state, controller),
    );
  }

  Widget _body(LearningState state, dynamic controller) {
    if (state.status == LearningStatus.loading && state.videos.isEmpty) {
      return const LearningScreenSkeleton();
    }
    if (state.status == LearningStatus.offline && state.videos.isEmpty) {
      return AppOfflineView(onRetry: () => controller.load());
    }
    if (state.status == LearningStatus.failure && state.videos.isEmpty) {
      return AppErrorView(
        title: 'Learning unavailable',
        message:
            state.message ??
            'Learning content could not be loaded. Please try again.',
        retryLabel: 'Try again',
        onRetry: () => controller.load(),
      );
    }
    if (state.videos.isEmpty) {
      return const AppEmptyState(
        icon: Icons.menu_book_rounded,
        title: 'No learning videos yet',
        message:
            'Published learning videos will appear here when they become available.',
      );
    }
    final completed = state.videos
        .where((video) => video.progress?.isCompleted == true)
        .length;
    return RefreshIndicator(
      onRefresh: () => controller.load(refresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  borderColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 34,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$completed of ${state.videos.length} lessons completed',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              completed == 0
                                  ? 'Start a lesson and build your first learning streak.'
                                  : 'Continue learning to grow your practical eco skills.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                const AppSectionHeader(
                  title: 'Recommended lessons',
                  subtitle:
                      'Continue where you left off or discover a new topic.',
                ),
                const SizedBox(height: AppSpacing.smMd),
              ],
            ),
          ),
          SliverList.separated(
            itemCount: state.videos.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.smMd),
            itemBuilder: (context, index) {
              final video = state.videos[index];
              return LearningVideoCard(
                video: video,
                onTap: () =>
                    context.push(AppRoutes.learningVideoPath(video.id)),
              );
            },
          ),
          if (state.hasNext)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: FilledButton.tonal(
                    onPressed: controller.loadMore,
                    child: const Text('Load more lessons'),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}
