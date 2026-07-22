import '../models/daily_game_progress.dart';
import '../models/eco_game.dart';
import '../models/game_attempt.dart';

enum GamesPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class GamesState {
  const GamesState({
    this.phase = GamesPhase.initial,
    this.games = const [],
    this.dailyProgress,
    this.recentAttempts = const [],
    this.hasNext = false,
    this.isStale = false,
    this.message,
    this.dailyMessage,
    this.attemptsMessage,
  });
  final GamesPhase phase;
  final List<EcoGame> games;
  final DailyGameProgress? dailyProgress;
  final List<GameAttempt> recentAttempts;
  final bool hasNext;
  final bool isStale;
  final String? message;
  final String? dailyMessage;
  final String? attemptsMessage;
  GamesState copyWith({
    GamesPhase? phase,
    List<EcoGame>? games,
    DailyGameProgress? dailyProgress,
    List<GameAttempt>? recentAttempts,
    bool? hasNext,
    bool? isStale,
    String? message,
    String? dailyMessage,
    String? attemptsMessage,
    bool clearMessages = false,
  }) => GamesState(
    phase: phase ?? this.phase,
    games: games ?? this.games,
    dailyProgress: dailyProgress ?? this.dailyProgress,
    recentAttempts: recentAttempts ?? this.recentAttempts,
    hasNext: hasNext ?? this.hasNext,
    isStale: isStale ?? this.isStale,
    message: clearMessages ? null : message ?? this.message,
    dailyMessage: clearMessages ? null : dailyMessage ?? this.dailyMessage,
    attemptsMessage: clearMessages
        ? null
        : attemptsMessage ?? this.attemptsMessage,
  );
}
