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
      title: 'Learn',
      subtitle:
          'Keep learning, keep growing 🌱\nPractical lessons for a greener tomorrow.',
      actions: [
        IconButton(
          tooltip: 'Search lessons',
          onPressed: () {},
          icon: const Icon(Icons.search_rounded),
        ),
      ],
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
                  backgroundColor: const Color(0xFFFCFAFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  '$completed of ${state.videos.length} lessons completed',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    minHeight: 7,
                                    value: completed / state.videos.length,
                                    backgroundColor: const Color(0xFFE9E6ED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Image.asset(
                            'assets/images/onboarding/learn_progress_sprout.png',
                            width: 86,
                            height: 86,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                AppSectionHeader(
                  title: 'Continue Learning',
                  actionLabel: 'See all',
                ),
                const SizedBox(height: AppSpacing.smMd),
                LearningVideoCard(
                  video: state.videos.first,
                  featured: true,
                  onTap: () => context.push(
                    AppRoutes.learningVideoPath(state.videos.first.id),
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                const AppSectionHeader(
                  title: 'Recommended for You',
                  actionLabel: 'See all',
                ),
                const SizedBox(height: AppSpacing.smMd),
              ],
            ),
          ),
          SliverList.separated(
            itemCount: state.videos.length - 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.smMd),
            itemBuilder: (context, index) {
              final video = state.videos[index + 1];
              return LearningVideoCard(
                video: video,
                featured: false,
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
