class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, Object?> toJson() => {
    'email': email.trim(),
    'password': password,
  };

  @override
  String toString() => 'LoginRequest(email: [REDACTED], password: [REDACTED])';
}
