enum PointDirection { earned, spent, adjustment, unknown }

class PointTransaction {
  const PointTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.balanceAfter,
    required this.sourceType,
    required this.description,
    required this.createdAt,
  });
  factory PointTransaction.fromJson(Map<String, Object?> j) => PointTransaction(
    id: _i(j['id']),
    type: j['transaction_type'] is String
        ? j['transaction_type']! as String
        : '',
    points: _i(j['points']),
    balanceAfter: _i(j['balance_after']),
    sourceType: j['source_type'] is String ? j['source_type']! as String : '',
    description: j['description'] is String ? j['description']! as String : '',
    createdAt: DateTime.tryParse(
      j['created_at'] is String ? j['created_at']! as String : '',
    )?.toUtc(),
  );
  final int id, points, balanceAfter;
  final String type, sourceType, description;
  final DateTime? createdAt;
  PointDirection get direction => switch (type) {
    'EARN_COLLECTION' ||
    'EARN_VIDEO' ||
    'EARN_QUIZ' ||
    'EARN_GAME' ||
    'EARN_CHALLENGE' ||
    'BONUS' => PointDirection.earned,
    'REDEEM_REWARD' => PointDirection.spent,
    'ADJUSTMENT_ADD' ||
    'ADJUSTMENT_DEDUCT' ||
    'CORRECTION' => PointDirection.adjustment,
    _ => PointDirection.unknown,
  };
  String get label => switch (type) {
    'EARN_COLLECTION' => 'Recycling collection',
    'EARN_VIDEO' => 'Learning video',
    'EARN_QUIZ' => 'Quiz',
    'EARN_GAME' => 'Eco-game',
    'EARN_CHALLENGE' => 'Challenge',
    'BONUS' => 'Bonus',
    'REDEEM_REWARD' => 'Reward redemption',
    'ADJUSTMENT_ADD' ||
    'ADJUSTMENT_DEDUCT' ||
    'CORRECTION' => 'Points adjustment',
    _ => 'Points activity',
  };
  static int _i(Object? v) {
    if (v is int) return v;
    throw const FormatException('Invalid transaction number');
  }
}
