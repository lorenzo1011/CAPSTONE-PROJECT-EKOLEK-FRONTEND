import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/home_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/learning_providers.dart';
import '../providers/video_player_state.dart';
import '../widgets/video_detail_skeleton.dart';

class VideoDetailScreen extends ConsumerStatefulWidget {
  const VideoDetailScreen({super.key, required this.videoId});
  final int videoId;
  @override
  ConsumerState<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends ConsumerState<VideoDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(learningVideoControllerProvider(widget.videoId))
          .initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(
      learningVideoControllerProvider(widget.videoId),
    );
    final state = controller.state;
    ref.listen(learningVideoControllerProvider(widget.videoId), (
      previous,
      next,
    ) {
      final progress = next.state.progress;
      if (progress != null) {
        ref
            .read(learningControllerProvider)
            .updateProgress(widget.videoId, progress);
      }
      if (progress?.pointsAwardedNow == true &&
          previous?.state.progress?.pointsAwardedNow != true) {
        final user = ref.read(currentAuthUserProvider);
        if (user != null) {
          ref.read(homeControllerProvider).load(user, refresh: true);
        }
        ref.invalidate(walletActivityControllerProvider);
      }
    });
    return PopScope(
      onPopInvokedWithResult: (_, _) => controller.pause(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Learning video')),
        body: SafeArea(
          child: switch (state.status) {
            LearningPlaybackStatus.initial ||
            LearningPlaybackStatus.loading => const VideoDetailSkeleton(),
            LearningPlaybackStatus.failure => AppErrorView(
              title: 'Video unavailable',
              message:
                  state.message ??
                  'This learning video is currently unavailable.',
              retryLabel: 'Try again',
              onRetry: controller.initialize,
            ),
            _ => _content(context, controller),
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, dynamic controller) {
    final state = controller.state as LearningPlaybackState;
    final video = state.video!;
    final progress = state.progress;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: EdgeInsets.all(constraints.maxWidth >= 700 ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(controller: controller.player!),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (video.category.isNotEmpty)
                        Chip(label: Text(video.category)),
                      if (video.pointsReward != null)
                        Chip(
                          avatar: const Icon(Icons.eco_rounded, size: 18),
                          label: Text(
                            AppFormatters.pointReward(video.pointsReward),
                          ),
                        ),
                    ],
                  ),
                  if (video.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(video.description),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                progress?.isCompleted == true
                                    ? Icons.check_circle_rounded
                                    : Icons.timelapse_rounded,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  progress?.isCompleted == true
                                      ? 'Learning completed'
                                      : 'Your verified progress',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                AppFormatters.progressPercentage(
                                  progress?.watchPercentage ?? 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (progress?.watchPercentage ?? 0) / 100,
                          ),
                          if (progress?.pointsAwardedNow == true) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${AppFormatters.pointReward(progress!.pointsAwardedAmount)} added to your wallet.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                          if (state.message != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              state.message!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (video.quiz != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          video.quiz!.isUnlocked
                              ? Icons.quiz_rounded
                              : Icons.lock_rounded,
                        ),
                        title: Text(video.quiz!.title),
                        subtitle: Text(
                          video.quiz!.isUnlocked
                              ? 'Quiz unlocked'
                              : 'Complete this video to unlock the quiz.',
                        ),
                        trailing: video.quiz!.isUnlocked
                            ? const Icon(Icons.chevron_right_rounded)
                            : null,
                        enabled: video.quiz!.isUnlocked,
                        onTap: video.quiz!.isUnlocked
                            ? () => context.push(
                                AppRoutes.learningQuizPath(video.quiz!.id),
                                extra: video.quiz,
                              )
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
