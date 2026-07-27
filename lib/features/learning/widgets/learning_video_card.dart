import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/learning_video.dart';

class LearningVideoCard extends StatelessWidget {
  const LearningVideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.featured = false,
  });
  final LearningVideo video;
  final VoidCallback onTap;
  final bool featured;

  String get fallbackAsset {
    final value = '${video.title} ${video.category}'.toLowerCase();
    if (value.contains('compost')) {
      return 'assets/images/onboarding/learn_compost_bin.png';
    }
    if (value.contains('community')) {
      return 'assets/images/backgrounds/bg_community_tree_planting.png';
    }
    return 'assets/images/onboarding/learn_progress_sprout.png';
  }

  @override
  Widget build(BuildContext context) {
    final scaledTitleSize = MediaQuery.textScalerOf(context).scale(16);
    final textScale = scaledTitleSize / 16;
    final scaleOverflow = (textScale - 1).clamp(0.0, 1.0);
    final cardHeight =
        (featured ? 164.0 : 112.0) + scaleOverflow * (featured ? 250.0 : 190.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              Container(
                width: featured ? 94 : 78,
                margin: const EdgeInsets.all(6),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7E6),
                  borderRadius: AppRadius.mediumBorderRadius,
                ),
                child: video.thumbnailUrl?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: video.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            Image.asset(fallbackAsset, fit: BoxFit.cover),
                      )
                    : Image.asset(fallbackAsset, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.category.isEmpty
                            ? 'ECO LEARNING'
                            : video.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF159447),
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.18,
                        ),
                      ),
                      if (featured) ...[
                        const SizedBox(height: 3),
                        Text(
                          video.description.isEmpty
                              ? 'Continue your practical eco lesson.'
                              : video.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                height: 1.3,
                              ),
                        ),
                        const Spacer(),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            OutlinedButton.icon(
                              onPressed: onTap,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.smMd,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                size: 17,
                              ),
                              label: const Text('Continue'),
                            ),
                            _Points(video.pointsReward, compact: true),
                          ],
                        ),
                      ] else ...[
                        const Spacer(),
                        _CompactFooter(
                          completed: video.progress?.isCompleted == true,
                          points: video.pointsReward,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactFooter extends StatelessWidget {
  const _CompactFooter({required this.completed, required this.points});

  final bool completed;
  final int? points;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      completed ? 'Completed' : 'Practical lesson',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
    );
    final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 180 || textScale > 1.25;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              label,
              const SizedBox(height: AppSpacing.xxs),
              Align(
                alignment: Alignment.centerRight,
                child: _Points(points, compact: true),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: label),
            const SizedBox(width: AppSpacing.sm),
            _Points(points, compact: true),
          ],
        );
      },
    );
  }
}

class _Points extends StatelessWidget {
  const _Points(this.points, {this.compact = false});
  final int? points;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 8 : 9,
      vertical: compact ? 3 : 6,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F9E9),
      borderRadius: AppRadius.circularBorderRadius,
    ),
    child: Text(
      points == null ? '— pts' : AppFormatters.pointReward(points),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: const Color(0xFF087D3C),
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
