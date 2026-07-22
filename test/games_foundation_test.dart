import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/games/models/daily_game_progress.dart';
import 'package:ekolek_app/features/games/models/eco_game.dart';
import 'package:ekolek_app/features/games/models/game_attempt.dart';
import 'package:ekolek_app/features/games/models/game_availability.dart';
import 'package:ekolek_app/features/games/models/game_type.dart';
import 'package:ekolek_app/features/games/services/game_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verified games foundation', () {
    test('uses only resident-safe verified endpoints', () {
      expect(ApiEndpoints.games, 'mobile/games/');
      expect(ApiEndpoints.game(3), 'mobile/games/3/');
      expect(ApiEndpoints.dailyGameProgress, 'mobile/games/daily-progress/');
      expect(ApiEndpoints.gameAttempts, 'mobile/games/attempts/');
      expect(ApiEndpoints.games, isNot(contains('admin')));
    });
    test('parses verified resident game fields', () {
      final game = EcoGame.fromJson(_gameJson());
      expect(game.type, EcoGameType.ecoDefender);
      expect(game.pointsEarnedToday, 30);
      expect(game.remainingPointsToday, 15);
      expect(game.highScore, 1200);
    });
    test('unknown game type is unsupported', () {
      final json = _gameJson()..['game_type'] = 'FUTURE_GAME';
      final game = EcoGame.fromJson(json);
      expect(game.type, EcoGameType.unknown);
      expect(const GameRegistry().supports(game), isFalse);
    });
    test('no local game launches without a registered implementation', () {
      final game = EcoGame.fromJson(_gameJson());
      expect(const GameRegistry().supports(game), isFalse);
      expect(const GameRegistry().unsupportedReason(game), isNotEmpty);
    });
    test('daily-limit behavior uses explicit backend flags', () {
      final json = _gameJson()
        ..['points_earned_today'] = 45
        ..['remaining_points_today'] = 0
        ..['daily_limit_reached'] = true;
      final game = EcoGame.fromJson(json);
      expect(game.hasReachedDailyPointLimit, isTrue);
      expect(game.canStillPlayWithoutPoints, isTrue);
    });
    test('daily progress parses authoritative totals', () {
      final progress = DailyGameProgress.fromJson({
        'date': '2026-07-16',
        'total_points_earned': 30,
        'total_plays': 2,
        'games': [_gameJson()],
      });
      expect(progress.totalPointsEarned, 30);
      expect(progress.totalPlays, 2);
      expect(progress.games.single.id, 1);
    });
    test('recent attempt parses accepted backend values', () {
      final attempt = GameAttempt.fromJson({
        'id': 8,
        'game': 1,
        'game_title': 'Eco Defender',
        'game_type': 'ECO_DEFENDER',
        'score': 900,
        'points_earned': 15,
        'played_at': '2026-07-16T00:00:00Z',
      });
      expect(attempt.score, 900);
      expect(attempt.pointsEarned, 15);
    });
    test('unknown availability fails safely', () {
      expect(
        GameAvailability.fromBackend('MAINTENANCE'),
        GameAvailability.unknown,
      );
      expect(GameAvailability.unknown.label, isNotEmpty);
    });
  });
}

Map<String, Object?> _gameJson() => {
  'id': 1,
  'title': 'Eco Defender',
  'description': 'Protect nature.',
  'game_type': 'ECO_DEFENDER',
  'points_per_play': 15,
  'daily_points_limit': 45,
  'points_earned_today': 30,
  'remaining_points_today': 15,
  'play_count_today': 2,
  'high_score': 1200,
  'latest_score': 800,
  'is_daily_limit_enabled': true,
  'daily_limit_reached': false,
  'play_allowed_after_limit': true,
};
