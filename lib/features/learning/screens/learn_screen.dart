import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/learning_providers.dart';
import '../../../app/app_routes.dart';
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
      subtitle: 'Build better recycling habits',
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
    return RefreshIndicator(
      onRefresh: () => controller.load(refresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.videos.length + (state.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.videos.length) {
            controller.loadMore();
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final video = state.videos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LearningVideoCard(
              video: video,
              onTap: () => context.push(AppRoutes.learningVideoPath(video.id)),
            ),
          );
        },
      ),
    );
  }
}
