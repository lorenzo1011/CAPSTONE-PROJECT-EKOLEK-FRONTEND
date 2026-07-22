import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/resident_status_storage.dart';
import '../models/resident_account_status.dart';
import '../services/account_status_service.dart';
import 'account_status_state.dart';
import 'auth_controller.dart';

class AccountStatusController extends ChangeNotifier {
  AccountStatusController({
    required AccountStatusService service,
    required ResidentStatusStorage storage,
    required AuthController authController,
    this.cooldown = const Duration(seconds: 8),
  }) : _service = service,
       _storage = storage,
       _authController = authController;

  final AccountStatusService _service;
  final ResidentStatusStorage _storage;
  final AuthController _authController;
  final Duration cooldown;
  AccountStatusState _state = const AccountStatusState();
  CancelToken? _cancelToken;
  Future<bool>? _activeRequest;
  DateTime? _lastAttempt;

  AccountStatusState get state => _state;

  Future<bool> refresh({bool manual = false}) {
    final active = _activeRequest;
    if (active != null) return active;
    final now = DateTime.now().toUtc();
    if (manual &&
        _lastAttempt != null &&
        now.difference(_lastAttempt!) < cooldown) {
      return Future.value(false);
    }
    _lastAttempt = now;
    final request = _refresh();
    _activeRequest = request;
    request.whenComplete(() => _activeRequest = null);
    return request;
  }

  Future<bool> _refresh() async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    _set(
      AccountStatusState(
        phase: _state.info == null
            ? AccountStatusPhase.loading
            : AccountStatusPhase.refreshing,
        info: _state.info,
        lastSuccessfulRefresh: _state.lastSuccessfulRefresh,
      ),
    );
    try {
      final info = await _service.getCurrentStatus(cancelToken: _cancelToken);
      final previous = await _storage.read(info.userId);
      final transitioned =
          previous != null &&
          previous.status != ResidentAccountStatus.approved.backendValue &&
          info.status.isApproved &&
          !previous.welcomeCompleted;
      final welcomeRequired =
          info.status.isApproved &&
          previous != null &&
          !previous.welcomeCompleted;
      final verifiedAt = DateTime.now().toUtc();
      await _storage.writeStatus(
        info.userId,
        info.status.backendValue,
        verifiedAt,
      );
      _authController.applyVerifiedAccountStatus(
        info,
        approvedWelcomeRequired: welcomeRequired,
      );
      _set(
        AccountStatusState(
          phase: AccountStatusPhase.loaded,
          info: info,
          lastSuccessfulRefresh: verifiedAt,
          approvalTransitionDetected: transitioned,
        ),
      );
      return true;
    } on NoInternetException catch (error) {
      _recover(AccountStatusPhase.offline, error.message);
      return false;
    } on NetworkException catch (error) {
      _recover(AccountStatusPhase.offline, error.message);
      return false;
    } on CancelledRequestException {
      return false;
    } on UnauthorizedException {
      _recover(
        AccountStatusPhase.failure,
        'Your session has expired. Please sign in again.',
      );
      return false;
    } on RateLimitException catch (error) {
      _recover(AccountStatusPhase.failure, error.message);
      return false;
    } on AppException {
      _recover(
        AccountStatusPhase.failure,
        'E-KOLEK could not verify your account status. Please try again later.',
      );
      return false;
    }
  }

  Future<void> completeWelcome() async {
    final info = _state.info;
    final user = _authController.state.user;
    final userId = info?.userId ?? user?.id;
    final verifiedApproved =
        info?.status.isApproved ?? (user?.isApprovedResident ?? false);
    if (userId == null || !verifiedApproved) return;
    await _storage.markWelcomeCompleted(userId);
    _authController.markApprovedWelcomeCompleted();
    if (info != null) {
      _set(
        AccountStatusState(
          phase: AccountStatusPhase.loaded,
          info: info,
          lastSuccessfulRefresh: _state.lastSuccessfulRefresh,
        ),
      );
    }
  }

  void reset() {
    _cancelToken?.cancel('Account status reset.');
    _state = const AccountStatusState();
    _lastAttempt = null;
    notifyListeners();
  }

  void _recover(AccountStatusPhase phase, String message) => _set(
    AccountStatusState(
      phase: phase,
      info: _state.info,
      lastSuccessfulRefresh: _state.lastSuccessfulRefresh,
      message: message,
    ),
  );

  void _set(AccountStatusState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Account status controller disposed.');
    super.dispose();
  }
}
