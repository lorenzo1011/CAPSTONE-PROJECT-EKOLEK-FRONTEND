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
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: featured ? 145 : 96,
        child: Row(
          children: [
            Container(
              width: featured ? 112 : 78,
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
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
                    const SizedBox(height: 5),
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (featured) ...[
                      const SizedBox(height: 5),
                      Text(
                        video.description.isEmpty
                            ? 'Continue your practical eco lesson.'
                            : video.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 17,
                            ),
                            label: const Text('Continue'),
                          ),
                          const Spacer(),
                          _Points(video.pointsReward),
                        ],
                      ),
                    ] else ...[
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            video.progress?.isCompleted == true
                                ? 'Completed'
                                : 'Practical lesson',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          _Points(video.pointsReward),
                        ],
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

class _Points extends StatelessWidget {
  const _Points(this.points);
  final int? points;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
