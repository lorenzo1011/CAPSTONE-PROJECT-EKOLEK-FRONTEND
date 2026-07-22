import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../models/achievement_badge.dart';

class AchievementBadgeCard extends StatelessWidget {
  const AchievementBadgeCard({
    super.key,
    required this.badge,
    required this.onTap,
  });
  final AchievementBadge badge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${badge.name}, ${badge.status.label}',
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'badge-${badge.id}',
                    child: _Artwork(badge: badge),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                badge.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                badge.badgeTypeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (badge.displayProgress != null) ...[
                Semantics(
                  label:
                      '${badge.progressValue} out of ${badge.progressTarget} ${badge.progressUnit ?? ''}',
                  child: LinearProgressIndicator(value: badge.displayProgress),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Row(
                children: [
                  Icon(badge.status.icon, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(badge.status.label, maxLines: 1)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.badge});
  final AchievementBadge badge;
  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: 42,
      child: Icon(badge.requirementType.icon, size: 42),
    );
    if (badge.iconUrl == null) return fallback;
    return CachedNetworkImage(
      imageUrl: badge.iconUrl!,
      fit: BoxFit.contain,
      memCacheWidth: 320,
      placeholder: (context, url) => fallback,
      errorWidget: (context, url, error) => fallback,
    );
  }
}
