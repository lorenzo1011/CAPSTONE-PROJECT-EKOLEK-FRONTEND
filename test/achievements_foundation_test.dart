import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/achievements/models/achievement_badge.dart';
import 'package:ekolek_app/features/achievements/models/achievement_summary.dart';
import 'package:ekolek_app/features/achievements/models/badge_requirement_type.dart';
import 'package:ekolek_app/features/achievements/models/badge_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verified resident achievements foundation', () {
    test('uses only resident-safe verified endpoints', () {
      expect(ApiEndpoints.badges, 'mobile/badges/');
      expect(ApiEndpoints.unlockedBadges, 'mobile/badges/unlocked/');
      expect(ApiEndpoints.badgeSummary, 'mobile/badges/summary/');
      expect(ApiEndpoints.badge(7), 'mobile/badges/7/');
      expect(ApiEndpoints.badges, isNot(contains('admin')));
    });

    test('parses authoritative badge progress and unlock fields', () {
      final badge = AchievementBadge.fromJson(_badgeJson());
      expect(badge.status, BadgeStatus.inProgress);
      expect(badge.requirementType, BadgeRequirementType.learningVideos);
      expect(badge.progressValue, 3);
      expect(badge.progressTarget, 5);
      expect(badge.isUnlocked, isFalse);
    });

    test('unknown status never appears unlocked', () {
      final badge = AchievementBadge.fromJson(
        _badgeJson()
          ..['status'] = 'FUTURE_STATE'
          ..['is_unlocked'] = true,
      );
      expect(badge.status, BadgeStatus.unknown);
      expect(badge.isUnlocked, isFalse);
    });

    test('display progress clamps without changing backend value', () {
      final badge = AchievementBadge.fromJson(
        _badgeJson()..['progress_percentage'] = 140.0,
      );
      expect(badge.progressPercentage, 140);
      expect(badge.displayProgress, 1);
    });

    test('missing progress remains unavailable', () {
      final badge = AchievementBadge.fromJson(
        _badgeJson()
          ..['progress_value'] = null
          ..['progress_target'] = null
          ..['progress_percentage'] = null,
      );
      expect(badge.progressValue, isNull);
      expect(badge.displayProgress, isNull);
    });

    test('summary parses backend authoritative totals and preview', () {
      final summary = AchievementSummary.fromJson({
        'total_visible_badges': 10,
        'total_unlocked_badges': 3,
        'total_locked_badges': 7,
        'completion_percentage': 30.0,
        'badges_by_type': {'LEARNING': 2},
        'latest_unlocked_badge': _badgeJson()
          ..['status'] = 'UNLOCKED'
          ..['is_unlocked'] = true,
      });
      expect(summary.totalVisible, 10);
      expect(summary.totalUnlocked, 3);
      expect(summary.latestUnlocked?.isUnlocked, isTrue);
    });

    test('models do not expose raw response data in toString', () {
      final badge = AchievementBadge.fromJson(_badgeJson());
      expect(badge.toString(), isNot(contains('Verified learning progress')));
      expect(badge.toString(), isNot(contains('https://')));
    });
  });
}

Map<String, Object?> _badgeJson() => {
  'id': 7,
  'name': 'Verified Learner',
  'description': 'Verified learning progress',
  'icon_url': 'https://example.com/badge.png',
  'badge_type': 'LEARNING',
  'badge_type_label': 'Learning',
  'condition_type': 'VIDEOS_COMPLETED',
  'condition_label': 'Videos Completed',
  'condition_value': 5,
  'progress_value': '3',
  'progress_target': '5',
  'progress_percentage': 60.0,
  'progress_unit': 'count',
  'status': 'IN_PROGRESS',
  'is_unlocked': false,
  'unlocked_at': null,
};
