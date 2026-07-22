import '../models/eco_challenge.dart';

enum ChallengesPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class ChallengesState {
  const ChallengesState({
    this.phase = ChallengesPhase.initial,
    this.items = const [],
    this.history = const [],
    this.hasNext = false,
    this.message,
    this.isStale = false,
  });

  final ChallengesPhase phase;
  final List<EcoChallenge> items;
  final List<EcoChallenge> history;
  final bool hasNext;
  final String? message;
  final bool isStale;

  EcoChallenge? get activePreview {
    for (final item in items) {
      if (item.status.name == 'active') return item;
    }
    return null;
  }

  ChallengesState copyWith({
    ChallengesPhase? phase,
    List<EcoChallenge>? items,
    List<EcoChallenge>? history,
    bool? hasNext,
    String? message,
    bool? isStale,
    bool clearMessage = false,
  }) => ChallengesState(
    phase: phase ?? this.phase,
    items: items ?? this.items,
    history: history ?? this.history,
    hasNext: hasNext ?? this.hasNext,
    message: clearMessage ? null : message ?? this.message,
    isStale: isStale ?? this.isStale,
  );
}
