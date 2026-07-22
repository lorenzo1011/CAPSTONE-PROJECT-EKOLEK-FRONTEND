import 'eco_game.dart';

class DailyGameProgress {
  const DailyGameProgress({
    required this.date,
    required this.totalPointsEarned,
    required this.totalPlays,
    required this.games,
  });
  factory DailyGameProgress.fromJson(Map<String, Object?> json) {
    final raw = json['games'];
    return DailyGameProgress(
      date: DateTime.parse(json['date'] as String),
      totalPointsEarned: json['total_points_earned'] as int,
      totalPlays: json['total_plays'] as int,
      games: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (item) => EcoGame.fromJson(
                    item.map((k, v) => MapEntry(k.toString(), v)),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
  final DateTime date;
  final int totalPointsEarned;
  final int totalPlays;
  final List<EcoGame> games;
}
