class GameAttempt {
  const GameAttempt({
    required this.id,
    required this.gameId,
    required this.gameTitle,
    required this.gameType,
    required this.score,
    required this.pointsEarned,
    this.playedAt,
  });
  factory GameAttempt.fromJson(Map<String, Object?> json) => GameAttempt(
    id: json['id'] as int,
    gameId: json['game'] as int,
    gameTitle: json['game_title'] as String? ?? '',
    gameType: json['game_type'] as String? ?? '',
    score: json['score'] as int,
    pointsEarned: json['points_earned'] as int,
    playedAt: DateTime.tryParse(json['played_at'] as String? ?? ''),
  );
  final int id;
  final int gameId;
  final String gameTitle;
  final String gameType;
  final int score;
  final int pointsEarned;
  final DateTime? playedAt;
}
