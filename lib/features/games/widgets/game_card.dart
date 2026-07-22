import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/eco_game.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, required this.onTap});
  final EcoGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${game.title}. ${game.type.label}. Available for details.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      child: Icon(Icons.sports_esports_rounded),
                    ),
                    const Spacer(),
                    Chip(label: Text(game.type.label)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (game.isDailyLimitEnabled) ...[
                  LinearProgressIndicator(
                    value: game.dailyPointsLimit == 0
                        ? 0
                        : game.pointsEarnedToday / game.dailyPointsLimit,
                    semanticsLabel: 'Daily game points progress',
                    semanticsValue:
                        '${game.pointsEarnedToday} of ${game.dailyPointsLimit} points',
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(
                      game.dailyLimitReached
                          ? Icons.info_outline_rounded
                          : Icons.eco_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        game.dailyLimitReached
                            ? 'Daily reward limit reached'
                            : '${AppFormatters.points(game.pointsPerPlay)} points per validated play',
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
