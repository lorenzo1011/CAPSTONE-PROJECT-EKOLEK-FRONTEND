import '../models/barangay_leaderboard_entry.dart';
import '../models/current_rank.dart';
import '../models/leaderboard_page.dart';
import '../models/leaderboard_scope.dart';
import '../models/resident_leaderboard_entry.dart';

enum LeaderboardPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class LeaderboardState {
  const LeaderboardState({
    this.phase = LeaderboardPhase.initial,
    this.scope = LeaderboardScope.barangayResidents,
    this.residentPage,
    this.barangayPage,
    this.residentRank,
    this.barangayRank,
    this.isStale = false,
    this.message,
  });
  final LeaderboardPhase phase;
  final LeaderboardScope scope;
  final LeaderboardPage<ResidentLeaderboardEntry>? residentPage;
  final LeaderboardPage<BarangayLeaderboardEntry>? barangayPage;
  final CurrentRank? residentRank, barangayRank;
  final bool isStale;
  final String? message;
  bool get hasData =>
      (scope == LeaderboardScope.barangayResidents
              ? residentPage?.items
              : barangayPage?.items)
          ?.isNotEmpty ==
      true;
  bool get hasNext => scope == LeaderboardScope.barangayResidents
      ? residentPage?.hasNext == true
      : barangayPage?.hasNext == true;
  LeaderboardState copyWith({
    LeaderboardPhase? phase,
    LeaderboardScope? scope,
    LeaderboardPage<ResidentLeaderboardEntry>? residentPage,
    LeaderboardPage<BarangayLeaderboardEntry>? barangayPage,
    CurrentRank? residentRank,
    CurrentRank? barangayRank,
    bool? isStale,
    String? message,
    bool clearMessage = false,
  }) => LeaderboardState(
    phase: phase ?? this.phase,
    scope: scope ?? this.scope,
    residentPage: residentPage ?? this.residentPage,
    barangayPage: barangayPage ?? this.barangayPage,
    residentRank: residentRank ?? this.residentRank,
    barangayRank: barangayRank ?? this.barangayRank,
    isStale: isStale ?? this.isStale,
    message: clearMessage ? null : message ?? this.message,
  );
}
