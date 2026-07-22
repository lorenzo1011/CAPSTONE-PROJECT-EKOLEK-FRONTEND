enum AuthSessionStatus {
  unknown,
  unauthenticated,
  authenticated,
  refreshing,
  expired,
}

class AuthSession {
  const AuthSession._({
    required this.status,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
    this.message,
  });

  const AuthSession.unknown() : this._(status: AuthSessionStatus.unknown);
  const AuthSession.unauthenticated()
    : this._(status: AuthSessionStatus.unauthenticated);
  const AuthSession.expired({String? message})
    : this._(status: AuthSessionStatus.expired, message: message);
  const AuthSession.refreshing({
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) : this._(
         status: AuthSessionStatus.refreshing,
         accessTokenExpiresAt: accessTokenExpiresAt,
         refreshTokenExpiresAt: refreshTokenExpiresAt,
       );
  const AuthSession.authenticated({
    required DateTime? accessTokenExpiresAt,
    required DateTime? refreshTokenExpiresAt,
  }) : this._(
         status: AuthSessionStatus.authenticated,
         accessTokenExpiresAt: accessTokenExpiresAt,
         refreshTokenExpiresAt: refreshTokenExpiresAt,
       );

  final AuthSessionStatus status;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;
  final String? message;

  bool get canRefresh =>
      status == AuthSessionStatus.authenticated ||
      status == AuthSessionStatus.refreshing;
}
