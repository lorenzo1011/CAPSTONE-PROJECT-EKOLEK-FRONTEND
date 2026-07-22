import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/leaderboard/models/barangay_leaderboard_entry.dart';
import 'package:ekolek_app/features/leaderboard/models/current_rank.dart';
import 'package:ekolek_app/features/leaderboard/models/leaderboard_metric.dart';
import 'package:ekolek_app/features/leaderboard/models/leaderboard_period.dart';
import 'package:ekolek_app/features/leaderboard/models/leaderboard_scope.dart';
import 'package:ekolek_app/features/leaderboard/models/resident_leaderboard_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Privacy-safe verified leaderboard foundation', () {
    test('uses only verified resident endpoints', () {
      expect(ApiEndpoints.leaderboard, 'mobile/leaderboard/');
      expect(ApiEndpoints.barangayLeaderboard, 'mobile/leaderboard/barangays/');
      expect(ApiEndpoints.currentResidentRank, 'mobile/leaderboard/me/');
      expect(
        ApiEndpoints.currentBarangayRank,
        'mobile/leaderboard/barangay/me/',
      );
      expect(ApiEndpoints.leaderboard, isNot(contains('admin')));
    });
    test('resident entry preserves backend rank and tie', () {
      final entry = ResidentLeaderboardEntry.fromJson({
        'rank': 2,
        'display_name': 'Eco Resident 0002',
        'score': 100,
        'score_unit': 'points',
        'is_current_user': false,
        'is_tied': true,
      });
      expect(entry.rank, 2);
      expect(entry.score, 100);
      expect(entry.isTied, isTrue);
    });
    test('resident model contains no private identity fields', () {
      final entry = ResidentLeaderboardEntry.fromJson({
        'rank': 1,
        'display_name': 'You',
        'score': 120,
        'score_unit': 'points',
        'is_current_user': true,
        'is_tied': false,
      });
      expect(entry.toString(), isNot(contains('email')));
      expect(entry.toString(), isNot(contains('resident_id')));
      expect(entry.isCurrentUser, isTrue);
    });
    test('barangay entry uses backend aggregate', () {
      final entry = BarangayLeaderboardEntry.fromJson({
        'rank': 1,
        'barangay_name': 'Barangay Uno',
        'score': '240.000',
        'score_unit': 'kg',
        'eligible_resident_count': 12,
        'is_current_barangay': true,
        'is_tied': false,
      });
      expect(entry.score, 240);
      expect(entry.eligibleResidentCount, 12);
      expect(entry.isCurrentBarangay, isTrue);
    });
    test('current rank supports unranked without rank zero', () {
      final rank = CurrentRank.fromJson({
        'rank': null,
        'score': null,
        'total_eligible_entries': 0,
        'is_ranked': false,
        'metric': 'TOTAL_EARNED_POINTS',
        'score_label': 'Lifetime points',
        'score_unit': 'points',
        'period': 'ALL_TIME',
        'updated_at': '2026-07-22T00:00:00Z',
      });
      expect(rank.rank, isNull);
      expect(rank.isRanked, isFalse);
    });
    test('unknown contract values remain unknown', () {
      expect(
        LeaderboardScope.fromJson('CITY_RESIDENTS'),
        LeaderboardScope.unknown,
      );
      expect(
        LeaderboardMetric.fromJson('ECO_SCORE'),
        LeaderboardMetric.unknown,
      );
      expect(LeaderboardPeriod.fromJson('SEASONAL'), LeaderboardPeriod.unknown);
    });
    test('supported periods are backend values only', () {
      expect(LeaderboardPeriod.monthly.value, 'MONTHLY');
      expect(LeaderboardPeriod.allTime.value, 'ALL_TIME');
    });
  });
}
