import 'dart:async';

import '../storage/token_storage.dart';
import 'auth_session.dart';
import 'auth_tokens.dart';

class AuthSessionManager {
  AuthSessionManager({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;
  final _sessionController = StreamController<AuthSession>.broadcast();
  AuthSession _session = const AuthSession.unknown();
  AuthTokens? _tokens;
  Future<AuthSession>? _initialization;

  AuthSession get session => _session;
  Stream<AuthSession> get sessionStream => _sessionController.stream;

  Future<AuthSession> initialize() => _initialization ??= _initialize();

  Future<AuthSession> _initialize() async {
    final tokens = await _tokenStorage.readTokens();
    if (tokens == null) {
      _setSession(const AuthSession.unauthenticated());
      return _session;
    }
    if (!tokens.hasUsableRefreshToken()) {
      await _tokenStorage.clearTokens();
      _tokens = null;
      _setSession(
        const AuthSession.expired(message: 'Your session has expired.'),
      );
      return _session;
    }
    _tokens = tokens;
    _setSession(_authenticatedSession(tokens));
    return _session;
  }

  Future<void> saveAuthenticatedSession(AuthTokens tokens) async {
    await _tokenStorage.saveTokens(tokens);
    _tokens = tokens;
    _setSession(_authenticatedSession(tokens));
  }

  Future<void> updateTokens(AuthTokens tokens) =>
      saveAuthenticatedSession(tokens);

  Future<String?> getAccessToken() async {
    await initialize();
    return _tokens?.accessToken;
  }

  Future<String?> getRefreshToken() async {
    await initialize();
    return _tokens?.refreshToken;
  }

  void markRefreshing() {
    final tokens = _tokens;
    if (tokens == null) return;
    _setSession(
      AuthSession.refreshing(
        accessTokenExpiresAt: tokens.accessTokenExpiresAt,
        refreshTokenExpiresAt: tokens.refreshTokenExpiresAt,
      ),
    );
  }

  Future<void> clearSession() async {
    await _tokenStorage.clearTokens();
    _tokens = null;
    _setSession(const AuthSession.unauthenticated());
  }

  Future<void> logout() => clearSession();

  Future<void> expireSession() async {
    await _tokenStorage.clearTokens();
    _tokens = null;
    _setSession(
      const AuthSession.expired(message: 'Your session has expired.'),
    );
  }

  AuthSession _authenticatedSession(AuthTokens tokens) =>
      AuthSession.authenticated(
        accessTokenExpiresAt: tokens.accessTokenExpiresAt,
        refreshTokenExpiresAt: tokens.refreshTokenExpiresAt,
      );

  void _setSession(AuthSession next) {
    if (_session.status == next.status &&
        _session.accessTokenExpiresAt == next.accessTokenExpiresAt &&
        _session.refreshTokenExpiresAt == next.refreshTokenExpiresAt &&
        _session.message == next.message) {
      return;
    }
    _session = next;
    if (!_sessionController.isClosed) _sessionController.add(next);
  }

  Future<void> dispose() => _sessionController.close();
}
