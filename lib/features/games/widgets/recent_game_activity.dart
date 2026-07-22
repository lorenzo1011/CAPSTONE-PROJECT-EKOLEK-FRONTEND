import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../models/game_attempt.dart';

class RecentGameActivity extends StatelessWidget {
  const RecentGameActivity({super.key, required this.attempts});
  final List<GameAttempt> attempts;
  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent game activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...attempts
                .take(3)
                .map(
                  (attempt) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history_rounded),
                    title: Text(attempt.gameTitle),
                    subtitle: Text(AppFormatters.dateTime(attempt.playedAt)),
                    trailing: Text(
                      '${attempt.score} score\n${attempt.pointsEarned} pts',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
