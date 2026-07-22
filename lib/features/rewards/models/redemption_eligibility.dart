class RedemptionEligibility {
  const RedemptionEligibility({
    required this.rewardId,
    required this.eligible,
    required this.reason,
    required this.pointsPerItem,
    required this.quantity,
    required this.totalPoints,
    required this.sufficientPoints,
    required this.stockAvailable,
    required this.quantityValid,
    required this.eventRequired,
    required this.eventEligible,
    required this.maximumQuantity,
    this.walletBalance,
    this.estimatedRemainingPoints,
    this.eventId,
  });
  factory RedemptionEligibility.fromJson(Map<String, Object?> j) =>
      RedemptionEligibility(
        rewardId: j['reward_id'] as int,
        eligible: j['eligible'] == true,
        reason:
            j['reason'] as String? ??
            'Your redemption eligibility could not be confirmed.',
        walletBalance: j['wallet_balance'] as int?,
        pointsPerItem: j['points_per_item'] as int,
        quantity: j['quantity'] as int,
        totalPoints: j['total_points'] as int,
        estimatedRemainingPoints: j['estimated_remaining_points'] as int?,
        sufficientPoints: j['sufficient_points'] == true,
        stockAvailable: j['stock_available'] == true,
        quantityValid: j['quantity_valid'] == true,
        eventRequired: j['event_required'] == true,
        eventEligible: j['event_eligible'] == true,
        eventId: j['event_id'] as int?,
        maximumQuantity: j['maximum_quantity'] as int,
      );
  final int rewardId, pointsPerItem, quantity, totalPoints, maximumQuantity;
  final int? walletBalance, estimatedRemainingPoints, eventId;
  final bool eligible,
      sufficientPoints,
      stockAvailable,
      quantityValid,
      eventRequired,
      eventEligible;
  final String reason;
}
