class WalletSummary {
  const WalletSummary({
    required this.id,
    required this.currentBalance,
    required this.lifetimeEarned,
    required this.lifetimeRedeemed,
    required this.lifetimeAdjusted,
    this.updatedAt,
  });
  factory WalletSummary.fromJson(Map<String, Object?> json) => WalletSummary(
    id: _int(json['id'], 'id'),
    currentBalance: _int(json['current_balance'], 'current_balance'),
    lifetimeEarned: _int(
      json['lifetime_points_earned'],
      'lifetime_points_earned',
    ),
    lifetimeRedeemed: _int(
      json['lifetime_points_redeemed'],
      'lifetime_points_redeemed',
    ),
    lifetimeAdjusted: _int(
      json['lifetime_points_adjusted'],
      'lifetime_points_adjusted',
    ),
    updatedAt: json['updated_at'] is String
        ? DateTime.tryParse(json['updated_at']! as String)?.toUtc()
        : null,
  );
  final int id,
      currentBalance,
      lifetimeEarned,
      lifetimeRedeemed,
      lifetimeAdjusted;
  final DateTime? updatedAt;
  bool get hasPoints => currentBalance > 0;
  static int _int(Object? value, String field) {
    if (value is int) return value;
    throw FormatException('Invalid $field');
  }
}
