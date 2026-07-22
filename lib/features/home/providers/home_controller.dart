import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/models/auth_user.dart';
import '../../wallet/models/wallet_summary.dart';
import '../../wallet/services/wallet_service.dart';
import '../models/home_dashboard_data.dart';
import 'home_state.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._service);
  final WalletService _service;
  HomeState state = const HomeState();
  Future<bool>? _active;
  CancelToken? _cancel;
  bool _disposed = false;
  Future<bool> load(AuthUser user, {bool refresh = false}) {
    if (_active != null) return _active!;
    if (!user.isApprovedResident) return Future.value(false);
    final f = _load(user, refresh);
    _active = f;
    f.whenComplete(() => _active = null);
    return f;
  }

  Future<bool> _load(AuthUser user, bool refresh) async {
    _cancel = CancelToken();
    state = HomeState(
      phase: state.data == null ? HomePhase.loading : HomePhase.refreshing,
      data: state.data,
    );
    notifyListeners();
    final previous = state.data;
    WalletSummary? wallet = previous?.wallet;
    var transactions = previous?.transactions ?? const [];
    String? walletMessage;
    String? transactionsMessage;
    try {
      try {
        wallet = await _service.getWalletSummary(cancelToken: _cancel);
      } on AppException catch (error) {
        walletMessage = 'Your point balance could not be refreshed.';
        if (error is NetworkException && previous == null) {
          walletMessage =
              'Cannot reach the E-KOLEK server. Check your connection and try again.';
        }
      } on FormatException {
        walletMessage = 'The wallet response could not be read.';
      }
      try {
        final page = await _service.getPointTransactions(
          pageSize: 5,
          cancelToken: _cancel,
        );
        transactions = page.items;
      } on AppException {
        transactionsMessage = 'Recent point activity could not be refreshed.';
      } on FormatException {
        transactionsMessage = 'Recent point activity could not be read.';
      }
      state = HomeState(
        phase: HomePhase.loaded,
        data: HomeDashboardData(
          userId: user.id,
          displayName: user.fullName,
          wallet: wallet,
          transactions: transactions,
          refreshedAt: DateTime.now().toUtc(),
        ),
        walletMessage: walletMessage,
        transactionsMessage: transactionsMessage,
        stale: walletMessage != null || transactionsMessage != null,
      );
      if (!_disposed) notifyListeners();
      return true;
    } on NetworkException {
      state = HomeState(
        phase: HomePhase.offline,
        data: state.data,
        message:
            'You appear to be offline. Connect to the internet and try again.',
        stale: state.data != null,
      );
      if (!_disposed) notifyListeners();
      return false;
    } on AppException {
      state = HomeState(
        phase: HomePhase.failure,
        data: state.data,
        message:
            'Your wallet information could not be loaded. Please try again.',
        stale: state.data != null,
      );
      if (!_disposed) notifyListeners();
      return false;
    }
  }

  void reset() {
    _cancel?.cancel();
    state = const HomeState();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancel?.cancel();
    super.dispose();
  }
}
