import '../../events/models/resident_event.dart';
import 'redemption_status.dart';
import 'resident_redemption_item.dart';

class ResidentRedemption {
  const ResidentRedemption({
    required this.id,
    required this.status,
    required this.item,
    required this.requestedAt,
    required this.cancellationAllowed,
    required this.pointsEffect,
    required this.stockEffect,
    this.referenceCode,
    this.event,
    this.expiresAt,
    this.completedAt,
    this.cancelledAt,
    this.updatedAt,
  });
  factory ResidentRedemption.fromJson(Map<String, Object?> j) {
    final reward = j['reward'];
    if (reward is! Map) throw const FormatException('Invalid reward');
    final quantity = j['quantity'] as int,
        ppi = j['points_per_item'] as int,
        total = j['total_points'] as int;
    final event = j['event'];
    return ResidentRedemption(
      id: j['id'] as int,
      referenceCode: j['reference_code'] as String?,
      status: RedemptionStatusX.parse(j['status']),
      item: ResidentRedemptionItem(
        rewardId: reward['id'] as int,
        rewardName: reward['name'] as String,
        quantity: quantity,
        pointsPerItem: ppi,
        totalPoints: total,
        imageUrl: reward['image_url'] as String?,
      ),
      event: event is Map
          ? ResidentEvent.fromJson(
              event.map((k, v) => MapEntry(k.toString(), v)),
              ResidentEventType.rewardDistribution,
            )
          : null,
      requestedAt: DateTime.parse(j['reserved_at'] as String).toUtc(),
      expiresAt: _date(j['expires_at']),
      completedAt: _date(j['claimed_at']),
      cancelledAt: _date(j['cancelled_at']),
      updatedAt: _date(j['updated_at']),
      cancellationAllowed: j['cancellation_allowed'] == true,
      pointsEffect: j['points_effect'] as String? ?? 'UNKNOWN',
      stockEffect: j['stock_effect'] as String? ?? 'UNKNOWN',
    );
  }
  final int id;
  final String? referenceCode;
  final RedemptionStatus status;
  final ResidentRedemptionItem item;
  final ResidentEvent? event;
  final DateTime requestedAt;
  final DateTime? expiresAt, completedAt, cancelledAt, updatedAt;
  final bool cancellationAllowed;
  final String pointsEffect, stockEffect;
  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
