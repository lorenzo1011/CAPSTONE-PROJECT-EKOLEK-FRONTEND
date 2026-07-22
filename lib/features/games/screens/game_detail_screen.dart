import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/games_providers.dart';
import '../models/eco_game.dart';
import '../widgets/game_detail_skeleton.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.gameId});
  final int gameId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(gameDetailProvider(gameId));
    return Scaffold(
      appBar: AppBar(title: const Text('Game details')),
      body: SafeArea(
        child: detail.when(
          loading: () => const GameDetailSkeleton(),
          error: (_, _) => AppErrorView(
            title: 'Game unavailable',
            message: 'This game is currently unavailable.',
            retryLabel: 'Try again',
            onRetry: () => ref.invalidate(gameDetailProvider(gameId)),
          ),
          data: (game) => _content(context, ref, game),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, EcoGame game) {
    final registry = ref.watch(gameRegistryProvider);
    final supported = registry.supports(game);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.sports_esports_rounded, size: 72),
              ),
            ),
            const SizedBox(height: 24),
            Text(game.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Chip(label: Text(game.type.label)),
            if (game.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(game.description),
            ],
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row(
                      'Validated play reward',
                      '${AppFormatters.points(game.pointsPerPlay)} points',
                    ),
                    if (game.isDailyLimitEnabled)
                      _row(
                        'Daily reward limit',
                        '${AppFormatters.points(game.dailyPointsLimit)} points',
                      ),
                    _row(
                      'Earned today',
                      '${AppFormatters.points(game.pointsEarnedToday)} points',
                    ),
                    if (game.isDailyLimitEnabled)
                      _row(
                        'Remaining today',
                        '${AppFormatters.points(game.remainingPointsToday)} points',
                      ),
                    _row('Plays today', '${game.playCountToday}'),
                    if (game.highScore != null)
                      _row('Verified high score', '${game.highScore}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(
                supported ? 'Ready to play' : registry.unsupportedReason(game),
              ),
              subtitle: game.dailyLimitReached && game.playAllowedAfterLimit
                  ? const Text(
                      'The backend permits play after the daily reward limit, but no additional points may be awarded.',
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Semantics(
              label: supported
                  ? 'Play ${game.title}'
                  : 'Play disabled. ${registry.unsupportedReason(game)}',
              button: true,
              enabled: supported,
              child: FilledButton.icon(
                // No local game is registered yet, so this remains deliberately
                // disabled instead of exposing a placeholder interaction.
                onPressed: null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
