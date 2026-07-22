class ResidentRedemptionItem {
  const ResidentRedemptionItem({
    required this.rewardId,
    required this.rewardName,
    required this.quantity,
    required this.pointsPerItem,
    required this.totalPoints,
    this.imageUrl,
  });
  final int rewardId, quantity, pointsPerItem, totalPoints;
  final String rewardName;
  final String? imageUrl;
}
