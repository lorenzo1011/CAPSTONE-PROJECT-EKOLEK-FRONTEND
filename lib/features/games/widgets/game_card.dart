import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/eco_game.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, required this.onTap});
  final EcoGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 88,
        child: Row(
          children: [
            Container(
              width: 78,
              margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8E5),
                borderRadius: AppRadius.mediumBorderRadius,
              ),
              child: Image.asset(
                'assets/images/onboarding/games_eco_bird_runner.png',
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    game.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.type.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppFormatters.points(game.pointsPerPlay)} pts / play',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF159447),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(onPressed: onTap, child: const Text('Play')),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    ),
  );
}
