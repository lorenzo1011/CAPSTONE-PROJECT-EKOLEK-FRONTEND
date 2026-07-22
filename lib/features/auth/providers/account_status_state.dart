import '../models/account_status_info.dart';

enum AccountStatusPhase {
  initial,
  loading,
  loaded,
  refreshing,
  offline,
  failure,
}

class AccountStatusState {
  const AccountStatusState({
    this.phase = AccountStatusPhase.initial,
    this.info,
    this.lastSuccessfulRefresh,
    this.message,
    this.approvalTransitionDetected = false,
  });

  final AccountStatusPhase phase;
  final AccountStatusInfo? info;
  final DateTime? lastSuccessfulRefresh;
  final String? message;
  final bool approvalTransitionDetected;
  bool get isBusy =>
      phase == AccountStatusPhase.loading ||
      phase == AccountStatusPhase.refreshing;
  bool get manualRefreshAllowed => !isBusy;
}
