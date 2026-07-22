class RewardStock {
  const RewardStock({required this.availableQuantity});
  final int availableQuantity;
  bool get hasAvailableStock => availableQuantity > 0;
  bool canFulfillQuantity(int quantity) =>
      quantity > 0 && quantity <= availableQuantity;
  bool get shouldShowExactQuantity => true;
}
