import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/rewards/models/redemption_request.dart';
import 'package:ekolek_app/features/rewards/models/redemption_request_result.dart';
import 'package:ekolek_app/features/rewards/models/redemption_status.dart';
import 'package:ekolek_app/features/rewards/models/resident_redemption.dart';
import 'package:ekolek_app/features/rewards/screens/redemption_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Verified resident redemption request foundation', () {
    test('uses only verified resident reservation endpoints', () {
      expect(ApiEndpoints.redemptionRequests, 'mobile/reservations/');
      expect(ApiEndpoints.redemptionRequest(12), 'mobile/reservations/12/');
      expect(
        ApiEndpoints.cancelRedemptionRequest(12),
        'mobile/reservations/12/cancel/',
      );
      expect(
        ApiEndpoints.redemptionRequestLookup,
        'mobile/reservations/lookup/',
      );
      for (final path in [
        ApiEndpoints.redemptionRequests,
        ApiEndpoints.redemptionRequest(12),
      ]) {
        expect(path, isNot(contains('admin')));
        expect(path, isNot(contains('staff')));
        expect(path, isNot(contains('ekoscan')));
      }
    });

    test('request serializes verified fields without resident or barangay', () {
      const request = RedemptionRequest(
        rewardId: 7,
        quantity: 2,
        eventId: 4,
        idempotencyKey: 'private-key-00001',
      );
      expect(request.toJson().keys, {
        'reward_id',
        'quantity',
        'event_id',
        'idempotency_key',
      });
      expect(request.toJson(), isNot(contains('resident')));
      expect(request.toJson(), isNot(contains('barangay')));
      expect(request.toString(), isNot(contains('private-key-00001')));
    });

    test('maps only verified statuses and keeps unknown safe', () {
      expect(RedemptionStatusX.parse('PENDING'), RedemptionStatus.pending);
      expect(RedemptionStatusX.parse('APPROVED'), RedemptionStatus.approved);
      expect(RedemptionStatusX.parse('CLAIMED'), RedemptionStatus.completed);
      expect(RedemptionStatusX.parse('CANCELLED'), RedemptionStatus.cancelled);
      expect(RedemptionStatusX.parse('EXPIRED'), RedemptionStatus.expired);
      expect(RedemptionStatusX.parse('READY'), RedemptionStatus.unknown);
      expect(RedemptionStatusX.parse('READY').isActive, isFalse);
    });

    test('parses authoritative request without fabricating reference', () {
      final item = ResidentRedemption.fromJson(
        _redemptionJson()..['reference_code'] = null,
      );
      expect(item.referenceCode, isNull);
      expect(item.status, RedemptionStatus.pending);
      expect(item.item.totalPoints, 200);
      expect(item.cancellationAllowed, isTrue);
      expect(item.pointsEffect, 'NOT_DEDUCTED_BY_REQUEST');
      expect(item.stockEffect, 'RESERVED');
    });

    testWidgets('request result never claims reward received', (tester) async {
      final result = RedemptionRequestResult(
        requestCreated: true,
        duplicateRequest: false,
        redemption: ResidentRedemption.fromJson(_redemptionJson()),
      );
      await tester.pumpWidget(
        MaterialApp(home: RedemptionResultScreen(result: result)),
      );
      expect(find.text('Redemption request submitted'), findsOneWidget);
      expect(
        find.textContaining('not proof of physical reward release'),
        findsOneWidget,
      );
      expect(find.textContaining('Reward received'), findsNothing);
    });
  });
}

Map<String, Object?> _redemptionJson() => {
  'id': 15,
  'reference_code': 'RSV-2026-000015',
  'status': 'PENDING',
  'reward': {'id': 7, 'name': 'Eco Bag', 'image_url': null},
  'event': {
    'id': 4,
    'title': 'Reward Day',
    'barangay': {'id': 2, 'name': 'Langgam'},
    'event_date': '2026-07-22',
    'start_time': '09:00:00',
    'end_time': '12:00:00',
    'location': 'Barangay Hall',
    'status': 'ACTIVE',
  },
  'quantity': 2,
  'points_per_item': 100,
  'total_points': 200,
  'reserved_at': '2026-07-22T10:00:00Z',
  'expires_at': null,
  'claimed_at': null,
  'cancelled_at': null,
  'updated_at': '2026-07-22T10:00:00Z',
  'cancellation_allowed': true,
  'points_effect': 'NOT_DEDUCTED_BY_REQUEST',
  'stock_effect': 'RESERVED',
};
