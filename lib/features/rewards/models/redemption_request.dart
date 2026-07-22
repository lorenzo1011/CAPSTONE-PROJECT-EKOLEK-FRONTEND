class RedemptionRequest {
  const RedemptionRequest({
    required this.rewardId,
    required this.quantity,
    required this.eventId,
    required this.idempotencyKey,
  });
  final int rewardId, quantity, eventId;
  final String idempotencyKey;
  Map<String, Object?> toJson() => {
    'reward_id': rewardId,
    'quantity': quantity,
    'event_id': eventId,
    'idempotency_key': idempotencyKey,
  };
  @override
  String toString() =>
      'RedemptionRequest(rewardId: $rewardId, quantity: $quantity, eventId: $eventId)';
}
