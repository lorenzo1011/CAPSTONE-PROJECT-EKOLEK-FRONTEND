import '../models/redemption_history_filter.dart';
import '../models/resident_redemption.dart';

enum RedemptionHistoryPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class RedemptionHistoryState {
  const RedemptionHistoryState({
    this.phase = RedemptionHistoryPhase.initial,
    this.items = const [],
    this.filter = RedemptionHistoryFilter.all,
    this.hasNext = false,
    this.stale = false,
    this.message,
  });
  final RedemptionHistoryPhase phase;
  final List<ResidentRedemption> items;
  final RedemptionHistoryFilter filter;
  final bool hasNext, stale;
  final String? message;
  RedemptionHistoryState copyWith({
    RedemptionHistoryPhase? phase,
    List<ResidentRedemption>? items,
    RedemptionHistoryFilter? filter,
    bool? hasNext,
    bool? stale,
    String? message,
    bool clearMessage = false,
  }) => RedemptionHistoryState(
    phase: phase ?? this.phase,
    items: items ?? this.items,
    filter: filter ?? this.filter,
    hasNext: hasNext ?? this.hasNext,
    stale: stale ?? this.stale,
    message: clearMessage ? null : message ?? this.message,
  );
}
