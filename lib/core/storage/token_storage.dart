import '../auth/auth_tokens.dart';

abstract interface class TokenStorage {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> readTokens();
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> clearTokens();
  Future<bool> hasTokens();
}
