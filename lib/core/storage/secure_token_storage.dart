import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/auth_tokens.dart';
import '../errors/app_exception.dart';
import 'token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'ekolek.auth.access_token';
  static const _refreshKey = 'ekolek.auth.refresh_token';
  static const _accessExpiryKey = 'ekolek.auth.access_expires_at';
  static const _refreshExpiryKey = 'ekolek.auth.refresh_expires_at';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await _storage.write(key: _accessKey, value: tokens.accessToken);
      await _storage.write(key: _refreshKey, value: tokens.refreshToken);
      await _writeDate(_accessExpiryKey, tokens.accessTokenExpiresAt);
      await _writeDate(_refreshExpiryKey, tokens.refreshTokenExpiresAt);
    } on Object catch (error) {
      await _bestEffortClear();
      throw UnknownAppException(
        message: 'Secure session data could not be saved.',
        developerMessage: 'Secure token write failed: ${error.runtimeType}',
        originalError: error,
      );
    }
  }

  @override
  Future<AuthTokens?> readTokens() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      if (access == null && refresh == null) return null;
      if (access == null ||
          refresh == null ||
          access.trim().isEmpty ||
          refresh.trim().isEmpty) {
        await clearTokens();
        return null;
      }
      final accessExpiry = _parseDate(
        await _storage.read(key: _accessExpiryKey),
      );
      final refreshExpiry = _parseDate(
        await _storage.read(key: _refreshExpiryKey),
      );
      return AuthTokens(
        accessToken: access,
        refreshToken: refresh,
        accessTokenExpiresAt: accessExpiry,
        refreshTokenExpiresAt: refreshExpiry,
      );
    } on AppException {
      rethrow;
    } on Object catch (error) {
      await _bestEffortClear();
      throw UnknownAppException(
        message: 'Secure session data could not be read.',
        developerMessage: 'Secure token read failed: ${error.runtimeType}',
        originalError: error,
      );
    }
  }

  @override
  Future<String?> readAccessToken() async => (await readTokens())?.accessToken;

  @override
  Future<String?> readRefreshToken() async =>
      (await readTokens())?.refreshToken;

  @override
  Future<void> clearTokens() async {
    try {
      await _bestEffortClear();
    } on Object catch (error) {
      throw UnknownAppException(
        message: 'Secure session data could not be cleared.',
        developerMessage: 'Secure token clear failed: ${error.runtimeType}',
        originalError: error,
      );
    }
  }

  @override
  Future<bool> hasTokens() async => (await readTokens()) != null;

  Future<void> _writeDate(String key, DateTime? value) =>
      _storage.write(key: key, value: value?.toUtc().toIso8601String());

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  Future<void> _bestEffortClear() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _accessExpiryKey),
      _storage.delete(key: _refreshExpiryKey),
    ]);
  }
}
