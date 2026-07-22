import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/auth/auth_session_manager.dart';
import '../../../core/auth/session_expired_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/storage/resident_status_storage.dart';
import '../models/auth_user.dart';
import '../models/account_status_info.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required AuthSessionManager sessionManager,
    required SessionExpiredHandler sessionExpiredHandler,
    ResidentStatusStorage? residentStatusStorage,
  }) : _authService = authService,
       _sessionManager = sessionManager,
       _sessionExpiredHandler = sessionExpiredHandler,
       _residentStatusStorage = residentStatusStorage {
    _expiredSubscription = _sessionExpiredHandler.events.listen((_) {
      _setState(
        const AuthenticationState.unauthenticated(
          message: 'Your session has expired. Please sign in again.',
        ),
      );
    });
  }

  final AuthService _authService;
  final AuthSessionManager _sessionManager;
  final SessionExpiredHandler _sessionExpiredHandler;
  final ResidentStatusStorage? _residentStatusStorage;
  late final StreamSubscription<void> _expiredSubscription;
  AuthenticationState _state = const AuthenticationState.initial();
  Future<void>? _initialization;
  bool _loginInProgress = false;
  bool _logoutInProgress = false;

  AuthenticationState get state => _state;
  bool get isLoggingOut => _logoutInProgress;

  void applyVerifiedAccountStatus(
    AccountStatusInfo info, {
    bool approvedWelcomeRequired = false,
  }) {
    final user = _state.user;
    if (_state.status != AuthenticationStatus.authenticated ||
        user == null ||
        user.id != info.userId) {
      return;
    }
    final status = ResidentApprovalStatus.fromJson(info.status.backendValue);
    _setState(
      AuthenticationState.authenticated(
        user.copyWith(
          approvalStatus: status,
          fullName: info.displayName,
          residentProfileId: info.profileId,
          rejectionReason: info.rejectionReason,
          clearRejectionReason: info.rejectionReason == null,
        ),
        approvedWelcomeRequired: approvedWelcomeRequired,
      ),
    );
  }

  void markApprovedWelcomeCompleted() {
    final user = _state.user;
    if (user == null || !_state.approvedWelcomeRequired) return;
    _setState(AuthenticationState.authenticated(user));
  }

  Future<void> initialize({Duration minimumDuration = Duration.zero}) =>
      _initialization ??= _initialize(minimumDuration);

  Future<void> _initialize(Duration minimumDuration) async {
    final startedAt = DateTime.now();
    _setState(const AuthenticationState.loading());
    AuthenticationState outcome;
    try {
      final session = await _sessionManager.initialize();
      if (session.status == AuthSessionStatus.unauthenticated ||
          session.status == AuthSessionStatus.expired) {
        outcome = AuthenticationState.unauthenticated(message: session.message);
      } else {
        outcome = await _loadVerifiedUser();
        if (outcome.status != AuthenticationStatus.authenticated) {
          await _sessionManager.clearSession();
        }
      }
    } on AppException catch (error) {
      await _sessionManager.clearSession();
      outcome = AuthenticationState.unauthenticated(
        message: _safeMessage(error),
      );
    } on Object {
      await _sessionManager.clearSession();
      outcome = const AuthenticationState.unauthenticated();
    }
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minimumDuration) {
      await Future<void>.delayed(minimumDuration - elapsed);
    }
    _setState(outcome);
  }

  Future<bool> login(LoginRequest request) async {
    if (_loginInProgress) return false;
    _loginInProgress = true;
    _setState(const AuthenticationState.loading());
    try {
      final result = await _authService.login(request);
      await _sessionManager.saveAuthenticatedSession(result.tokens);
      final verifiedState = await _loadVerifiedUser();
      if (verifiedState.status != AuthenticationStatus.authenticated) {
        await _sessionManager.clearSession();
        _setState(verifiedState);
        return false;
      }
      _sessionExpiredHandler.reset();
      _setState(verifiedState);
      return true;
    } on ValidationException catch (error) {
      final hasNonFieldError =
          error.fieldErrors['non_field_errors']?.isNotEmpty ?? false;
      _setState(
        AuthenticationState.validationError(
          fieldErrors: error.fieldErrors,
          message: hasNonFieldError
              ? 'The provided login details are incorrect.'
              : error.message,
        ),
      );
      return false;
    } on AppException catch (error) {
      await _sessionManager.clearSession();
      _setState(AuthenticationState.failure(_safeMessage(error)));
      return false;
    } on Object {
      await _sessionManager.clearSession();
      _setState(
        const AuthenticationState.failure(
          'E-KOLEK is temporarily unavailable. Please try again later.',
        ),
      );
      return false;
    } finally {
      _loginInProgress = false;
    }
  }

  Future<AuthenticationState> _loadVerifiedUser() async {
    final user = await _authService.getCurrentUser();
    if (user.role != UserRole.resident) {
      return const AuthenticationState.failure(
        'This account is not authorized to use the E-KOLEK Resident App.',
      );
    }
    var welcomeRequired = false;
    final storage = _residentStatusStorage;
    if (storage != null) {
      final previous = await storage.read(user.id);
      welcomeRequired =
          user.isApprovedResident &&
          previous != null &&
          !previous.welcomeCompleted;
      await storage.writeStatus(
        user.id,
        user.approvalStatus.value,
        DateTime.now().toUtc(),
      );
    }
    return AuthenticationState.authenticated(
      user,
      approvedWelcomeRequired: welcomeRequired,
    );
  }

  Future<void> logout() async {
    if (_logoutInProgress) return;
    _logoutInProgress = true;
    notifyListeners();
    try {
      // The verified backend exposes no API logout/blacklist endpoint.
      await _sessionManager.logout();
    } finally {
      _sessionExpiredHandler.reset();
      _logoutInProgress = false;
      _setState(const AuthenticationState.unauthenticated());
    }
  }

  String _safeMessage(AppException error) {
    if (error is NetworkException || error is NoInternetException) {
      return 'You appear to be offline. Check your connection and try again.';
    }
    if (error is UnauthorizedException) {
      return 'The provided login details are incorrect.';
    }
    if (error is ServerException || error is RequestTimeoutException) {
      return 'E-KOLEK is temporarily unavailable. Please try again later.';
    }
    return error.message;
  }

  void _setState(AuthenticationState next) {
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _expiredSubscription.cancel();
    super.dispose();
  }
}
