import '../models/achievement_badge.dart';
import '../models/achievement_summary.dart';

enum AchievementsPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class AchievementsState {
  const AchievementsState({
    this.phase = AchievementsPhase.initial,
    this.badges = const [],
    this.summary,
    this.hasNext = false,
    this.isStale = false,
    this.message,
  });
  final AchievementsPhase phase;
  final List<AchievementBadge> badges;
  final AchievementSummary? summary;
  final bool hasNext;
  final bool isStale;
  final String? message;
  AchievementsState copyWith({
    AchievementsPhase? phase,
    List<AchievementBadge>? badges,
    AchievementSummary? summary,
    bool? hasNext,
    bool? isStale,
    String? message,
    bool clearMessage = false,
  }) => AchievementsState(
    phase: phase ?? this.phase,
    badges: badges ?? this.badges,
    summary: summary ?? this.summary,
    hasNext: hasNext ?? this.hasNext,
    isStale: isStale ?? this.isStale,
    message: clearMessage ? null : message ?? this.message,
  );
}
