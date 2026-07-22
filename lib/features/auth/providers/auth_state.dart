import '../models/auth_user.dart';

enum AuthenticationStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  validationError,
  failure,
}

class AuthenticationState {
  const AuthenticationState._({
    required this.status,
    this.user,
    this.message,
    this.fieldErrors = const {},
    this.approvedWelcomeRequired = false,
  });

  const AuthenticationState.initial()
    : this._(status: AuthenticationStatus.initial);
  const AuthenticationState.loading()
    : this._(status: AuthenticationStatus.loading);
  const AuthenticationState.unauthenticated({String? message})
    : this._(status: AuthenticationStatus.unauthenticated, message: message);
  const AuthenticationState.failure(String message)
    : this._(status: AuthenticationStatus.failure, message: message);
  const AuthenticationState.validationError({
    required Map<String, List<String>> fieldErrors,
    String? message,
  }) : this._(
         status: AuthenticationStatus.validationError,
         fieldErrors: fieldErrors,
         message: message,
       );
  const AuthenticationState.authenticated(
    AuthUser user, {
    bool approvedWelcomeRequired = false,
  }) : this._(
         status: AuthenticationStatus.authenticated,
         user: user,
         approvedWelcomeRequired: approvedWelcomeRequired,
       );

  final AuthenticationStatus status;
  final AuthUser? user;
  final String? message;
  final Map<String, List<String>> fieldErrors;
  final bool approvedWelcomeRequired;

  bool get isSubmitting => status == AuthenticationStatus.loading;
}
