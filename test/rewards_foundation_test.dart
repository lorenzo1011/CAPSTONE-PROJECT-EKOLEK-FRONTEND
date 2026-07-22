import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/rewards/models/redemption_preview.dart';
import 'package:ekolek_app/features/rewards/models/reward_availability.dart';
import 'package:ekolek_app/features/rewards/models/reward_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verified resident rewards foundation', () {
    test('uses only resident mobile reward endpoints', () {
      expect(ApiEndpoints.rewards, 'mobile/rewards/');
      expect(ApiEndpoints.reward(7), 'mobile/rewards/7/');
      expect(
        ApiEndpoints.rewardEligibility(7),
        'mobile/rewards/7/eligibility/',
      );
      expect(ApiEndpoints.rewardPreview(7), 'mobile/rewards/7/preview/');
      expect(ApiEndpoints.rewardValidEvents(7), 'mobile/rewards/7/events/');
      expect(ApiEndpoints.rewards, isNot(contains('admin')));
      expect(ApiEndpoints.rewards, isNot(contains('ekoscan')));
    });

    test('parses authoritative reward, stock, cost, and quantity fields', () {
      final reward = RewardItem.fromJson(_rewardJson());
      expect(reward.id, 9);
      expect(reward.pointsRequired, 125);
      expect(reward.stock.availableQuantity, 3);
      expect(reward.maximumQuantity, 3);
      expect(reward.requiresRewardEvent, isTrue);
      expect(reward.availability, RewardAvailability.available);
    });

    test('unknown availability cannot prepare redemption', () {
      final reward = RewardItem.fromJson(
        _rewardJson()..['availability'] = 'NEW_STATE',
      );
      expect(reward.availability, RewardAvailability.unknown);
      expect(reward.availability.canPrepare, isFalse);
    });

    test('missing point cost is rejected instead of displayed as free', () {
      expect(
        () => RewardItem.fromJson(_rewardJson()..remove('points_required')),
        throwsFormatException,
      );
    });

    test('preview remains explicitly non-committing with no reservation', () {
      final preview = RedemptionPreview.fromJson({
        'reward_id': 9,
        'eligible': true,
        'reason': 'Eligible for redemption review.',
        'wallet_balance': 500,
        'points_per_item': 125,
        'quantity': 2,
        'total_points': 250,
        'estimated_remaining_points': 250,
        'sufficient_points': true,
        'stock_available': true,
        'quantity_valid': true,
        'event_required': true,
        'event_eligible': true,
        'event_id': 4,
        'maximum_quantity': 3,
        'is_non_committing': true,
        'reservation_created': false,
      });
      expect(preview.isNonCommitting, isTrue);
      expect(preview.reservationCreated, isFalse);
      expect(preview.eligibility.totalPoints, 250);
    });
  });
}

Map<String, Object?> _rewardJson() => {
  'id': 9,
  'name': 'Eco Bag',
  'description': 'Reusable bag',
  'category': 'Household',
  'points_required': 125,
  'image_url': null,
  'availability': 'AVAILABLE',
  'available_quantity': 3,
  'minimum_quantity': 1,
  'maximum_quantity': 3,
  'requires_reward_event': true,
  'updated_at': '2026-07-22T10:00:00Z',
};
