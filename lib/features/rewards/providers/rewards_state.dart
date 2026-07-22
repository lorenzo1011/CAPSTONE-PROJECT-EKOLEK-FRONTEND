import '../models/reward_category.dart';
import '../models/reward_item.dart';

enum RewardsPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class RewardsState {
  const RewardsState({
    this.phase = RewardsPhase.initial,
    this.items = const [],
    this.categories = const [],
    this.selectedCategory,
    this.search = '',
    this.hasNext = false,
    this.stale = false,
    this.message,
  });
  final RewardsPhase phase;
  final List<RewardItem> items;
  final List<RewardCategory> categories;
  final String? selectedCategory, message;
  final String search;
  final bool hasNext, stale;
  RewardsState copyWith({
    RewardsPhase? phase,
    List<RewardItem>? items,
    List<RewardCategory>? categories,
    String? selectedCategory,
    String? search,
    bool? hasNext,
    bool? stale,
    String? message,
    bool clearCategory = false,
    bool clearMessage = false,
  }) => RewardsState(
    phase: phase ?? this.phase,
    items: items ?? this.items,
    categories: categories ?? this.categories,
    selectedCategory: clearCategory
        ? null
        : selectedCategory ?? this.selectedCategory,
    search: search ?? this.search,
    hasNext: hasNext ?? this.hasNext,
    stale: stale ?? this.stale,
    message: clearMessage ? null : message ?? this.message,
  );
}
