import '../../../core/auth/auth_tokens.dart';

class LoginResult {
  const LoginResult({required this.tokens});

  final AuthTokens tokens;

  @override
  String toString() => 'LoginResult(tokens: [REDACTED])';
}
