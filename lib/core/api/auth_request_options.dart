import 'package:dio/dio.dart';

class AuthRequestOptions {
  AuthRequestOptions._();

  static const requiresAuthentication = 'requiresAuthentication';
  static const skipTokenRefresh = 'skipTokenRefresh';
  static const tokenRefreshAttempted = 'tokenRefreshAttempted';

  static Options authenticated({bool skipRefresh = false}) => Options(
    extra: {requiresAuthentication: true, skipTokenRefresh: skipRefresh},
  );

  static Options public() =>
      Options(extra: {requiresAuthentication: false, skipTokenRefresh: true});

  static bool requiresAuth(RequestOptions options) =>
      options.extra[requiresAuthentication] == true;
  static bool skipsRefresh(RequestOptions options) =>
      options.extra[skipTokenRefresh] == true;
  static bool refreshAttempted(RequestOptions options) =>
      options.extra[tokenRefreshAttempted] == true;
}
