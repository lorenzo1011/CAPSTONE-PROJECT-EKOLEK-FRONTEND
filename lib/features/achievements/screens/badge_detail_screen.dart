import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/achievements_providers.dart';
import '../models/achievement_badge.dart';

class BadgeDetailScreen extends ConsumerWidget {
  const BadgeDetailScreen({super.key, required this.badgeId});
  final int badgeId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Achievement details')),
    body: ref
        .watch(achievementDetailProvider(badgeId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => AppErrorView(
            title: 'Achievement unavailable',
            message: 'This achievement is currently unavailable.',
            onRetry: () => ref.invalidate(achievementDetailProvider(badgeId)),
          ),
          data: (badge) => _Detail(badge: badge),
        ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.badge});
  final AchievementBadge badge;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: AppSpacing.screenPadding,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'badge-${badge.id}',
              child: SizedBox(
                height: 220,
                child: badge.iconUrl == null
                    ? Icon(badge.requirementType.icon, size: 120)
                    : CachedNetworkImage(
                        imageUrl: badge.iconUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) =>
                            Icon(badge.requirementType.icon, size: 120),
                      ),
              ),
            ),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Chip(
                avatar: Icon(badge.status.icon),
                label: Text(badge.status.label),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (badge.description.isNotEmpty)
              Text(
                badge.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified requirement',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(badge.requirementType.icon),
                      title: Text(badge.requirementLabel),
                      subtitle:
                          badge.progressValue == null ||
                              badge.progressTarget == null
                          ? const Text(
                              'Progress is unavailable for this requirement.',
                            )
                          : Text(
                              '${badge.progressValue} of ${badge.progressTarget} ${badge.progressUnit ?? ''}',
                            ),
                    ),
                    if (badge.displayProgress != null)
                      Semantics(
                        label:
                            '${badge.progressValue} out of ${badge.progressTarget}',
                        child: LinearProgressIndicator(
                          value: badge.displayProgress,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (badge.unlockedAt != null)
              ListTile(
                leading: const Icon(Icons.event_available_rounded),
                title: const Text('Unlocked'),
                subtitle: Text(AppFormatters.dateTime(badge.unlockedAt)),
              ),
          ],
        ),
      ),
    ),
  );
}
