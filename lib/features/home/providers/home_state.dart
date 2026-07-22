import '../models/home_dashboard_data.dart';

enum HomePhase { initial, loading, loaded, refreshing, offline, failure }

class HomeState {
  const HomeState({
    this.phase = HomePhase.initial,
    this.data,
    this.message,
    this.stale = false,
    this.walletMessage,
    this.transactionsMessage,
  });
  final HomePhase phase;
  final HomeDashboardData? data;
  final String? message;
  final bool stale;
  final String? walletMessage;
  final String? transactionsMessage;
  bool get busy => phase == HomePhase.loading || phase == HomePhase.refreshing;
}
