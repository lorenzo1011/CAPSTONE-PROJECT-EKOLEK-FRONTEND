import 'jwt_utils.dart';

class AuthTokens {
  AuthTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) : accessToken = _validate(accessToken, 'accessToken'),
       refreshToken = _validate(refreshToken, 'refreshToken'),
       accessTokenExpiresAt =
           accessTokenExpiresAt?.toUtc() ?? JwtUtils.expiration(accessToken),
       refreshTokenExpiresAt =
           refreshTokenExpiresAt?.toUtc() ?? JwtUtils.expiration(refreshToken);

  static const expirationLeeway = Duration(seconds: 30);

  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  bool isAccessTokenExpired({
    DateTime? now,
    Duration leeway = expirationLeeway,
  }) => _isExpired(accessTokenExpiresAt, now: now, leeway: leeway);

  bool isRefreshTokenExpired({
    DateTime? now,
    Duration leeway = expirationLeeway,
  }) => _isExpired(refreshTokenExpiresAt, now: now, leeway: leeway);

  bool hasUsableRefreshToken({DateTime? now}) =>
      refreshToken.isNotEmpty && !isRefreshTokenExpired(now: now);

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshTokenExpiresAt:
          refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
    );
  }

  static String _validate(String value, String name) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be empty.');
    }
    return trimmed;
  }

  static bool _isExpired(
    DateTime? expiration, {
    DateTime? now,
    required Duration leeway,
  }) {
    if (expiration == null) return true;
    return !(now ?? DateTime.now().toUtc()).add(leeway).isBefore(expiration);
  }

  @override
  String toString() =>
      'AuthTokens(accessToken: [REDACTED], refreshToken: [REDACTED], '
      'accessTokenExpiresAt: $accessTokenExpiresAt, '
      'refreshTokenExpiresAt: $refreshTokenExpiresAt)';
}
