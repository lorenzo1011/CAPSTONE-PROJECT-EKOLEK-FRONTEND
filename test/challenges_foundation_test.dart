import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/core/utils/formatters.dart';
import 'package:ekolek_app/features/challenges/models/challenge_status.dart';
import 'package:ekolek_app/features/challenges/models/challenge_type.dart';
import 'package:ekolek_app/features/challenges/models/eco_challenge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verified resident challenge foundation', () {
    test('uses only resident-safe verified endpoints', () {
      expect(ApiEndpoints.challenges, 'mobile/challenges/');
      expect(ApiEndpoints.challenge(7), 'mobile/challenges/7/');
      expect(ApiEndpoints.challengeProgress, 'mobile/challenges/progress/');
      expect(ApiEndpoints.challenges, isNot(contains('admin')));
    });

    test('parses authoritative challenge and progress fields', () {
      final challenge = EcoChallenge.fromJson(_json());
      expect(challenge.status, ChallengeStatus.active);
      expect(challenge.type, ChallengeType.completeVideos);
      expect(challenge.progress?.currentValue, 3);
      expect(challenge.progress?.percentage, 60);
      expect(challenge.progress?.isCompleted, isFalse);
    });

    test('unknown statuses and types fail safely', () {
      final json = _json()
        ..['status'] = 'FUTURE_STATE'
        ..['challenge_type'] = 'FUTURE_TYPE';
      final challenge = EcoChallenge.fromJson(json);
      expect(challenge.status, ChallengeStatus.unknown);
      expect(challenge.type, ChallengeType.unknown);
    });

    test('missing progress is not fabricated as zero progress', () {
      final challenge = EcoChallenge.fromJson(_json()..['progress'] = null);
      expect(challenge.progress, isNull);
      expect(challenge.isCompleted, isFalse);
    });

    test('display percentage clamps without changing backend value', () {
      final progress = EcoChallenge.fromJson(
        _json()
          ..['progress'] = {..._progress(), 'progress_percentage': '140.00'},
      ).progress!;
      expect(progress.percentage, 140);
      expect(progress.displayPercentage, 100);
    });

    test('reward appears only when backend confirms it', () {
      final progress = EcoChallenge.fromJson(_json()).progress!;
      expect(progress.pointsAwarded, isFalse);
      expect(progress.awardedPoints, isNull);
    });

    test('formatters preserve verified unit and large values', () {
      expect(AppFormatters.challengeValue(12000, 'videos'), '12,000 videos');
      expect(AppFormatters.challengePercentage(60), '60%');
    });
  });
}

Map<String, Object?> _json() => {
  'id': 7,
  'title': 'Learning Season',
  'description': 'Complete verified learning activities.',
  'challenge_type': 'COMPLETE_VIDEOS',
  'target_value': 5,
  'goal_unit': 'videos',
  'bonus_points': 25,
  'start_date': '2026-07-01',
  'end_date': '2026-07-31',
  'status': 'ACTIVE',
  'is_city_wide': true,
  'is_eligible': true,
  'progress': _progress(),
};

Map<String, Object?> _progress() => {
  'id': 2,
  'current_value': 3,
  'is_completed': false,
  'completed_at': null,
  'points_awarded': false,
  'awarded_points': null,
  'progress_percentage': '60.00',
  'created_at': '2026-07-01T00:00:00Z',
  'updated_at': '2026-07-16T00:00:00Z',
};
