enum RedemptionHistoryFilter {
  all,
  pending,
  approved,
  completed,
  cancelled,
  expired,
}

extension RedemptionHistoryFilterX on RedemptionHistoryFilter {
  String get label => switch (this) {
    RedemptionHistoryFilter.all => 'All',
    RedemptionHistoryFilter.pending => 'Pending',
    RedemptionHistoryFilter.approved => 'Approved',
    RedemptionHistoryFilter.completed => 'Released',
    RedemptionHistoryFilter.cancelled => 'Cancelled',
    RedemptionHistoryFilter.expired => 'Expired',
  };
  String? get query => switch (this) {
    RedemptionHistoryFilter.all => null,
    RedemptionHistoryFilter.pending => 'PENDING',
    RedemptionHistoryFilter.approved => 'APPROVED',
    RedemptionHistoryFilter.completed => 'CLAIMED',
    RedemptionHistoryFilter.cancelled => 'CANCELLED',
    RedemptionHistoryFilter.expired => 'EXPIRED',
  };
}
