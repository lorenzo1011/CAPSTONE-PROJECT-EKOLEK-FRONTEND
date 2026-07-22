import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/learning_video.dart';

class LearningVideoCard extends StatelessWidget {
  const LearningVideoCard({
    super.key,
    required this.video,
    required this.onTap,
  });
  final LearningVideo video;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final progress = video.progress;
    return Semantics(
      button: true,
      label:
          '${video.title}. ${progress?.isCompleted == true ? 'Completed' : '${progress?.watchPercentage ?? 0} percent watched'}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final image = _Thumbnail(
                video: video,
                width: compact ? 132 : 220,
              );
              final details = Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (video.category.isNotEmpty)
                        Text(
                          video.category.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (progress != null) ...[
                        LinearProgressIndicator(
                          value: progress.watchPercentage / 100,
                          semanticsLabel: 'Video progress',
                          semanticsValue: AppFormatters.progressPercentage(
                            progress.watchPercentage,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        children: [
                          Icon(
                            progress?.isCompleted == true
                                ? Icons.check_circle_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              progress?.isCompleted == true
                                  ? 'Completed'
                                  : progress?.canResume == true
                                  ? 'Continue learning'
                                  : 'Start learning',
                              maxLines: 1,
                            ),
                          ),
                          if (video.pointsReward != null)
                            Text(
                              AppFormatters.pointReward(video.pointsReward),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              return SizedBox(
                height: compact ? 132 : 150,
                child: Row(children: [image, details]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.video, required this.width});
  final LearningVideo video;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: double.infinity,
    child: video.thumbnailUrl?.isNotEmpty == true
        ? CachedNetworkImage(
            imageUrl: video.thumbnailUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            errorWidget: (_, _, _) => const _Fallback(),
          )
        : const _Fallback(),
  );
}

class _Fallback extends StatelessWidget {
  const _Fallback();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Center(child: Icon(Icons.ondemand_video_rounded, size: 38)),
  );
}
