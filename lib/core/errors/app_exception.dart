sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.developerMessage,
    this.statusCode,
    this.fieldErrors = const {},
    this.originalError,
  });

  final String message;
  final String? developerMessage;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;
  final Object? originalError;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'A network error occurred. Please try again.',
    super.developerMessage,
    super.statusCode,
    super.originalError,
  });
}

class NoInternetException extends AppException {
  const NoInternetException({
    super.message =
        'You appear to be offline. Check your connection and retry.',
    super.developerMessage,
    super.originalError,
  });
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException({
    super.message = 'The request took too long. Please try again.',
    super.developerMessage,
    super.statusCode,
    super.originalError,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Please sign in to continue.',
    super.developerMessage,
    super.statusCode = 401,
    super.originalError,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.developerMessage,
    super.statusCode = 403,
    super.originalError,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested information could not be found.',
    super.developerMessage,
    super.statusCode = 404,
    super.originalError,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Please check the information you entered.',
    super.developerMessage,
    super.statusCode = 400,
    super.fieldErrors,
    super.originalError,
  });
}

class ConflictException extends AppException {
  const ConflictException({
    super.message = 'This request conflicts with existing information.',
    super.developerMessage,
    super.statusCode = 409,
    super.originalError,
  });
}

class RateLimitException extends AppException {
  const RateLimitException({
    super.message = 'Too many requests. Please wait before trying again.',
    super.developerMessage,
    super.statusCode = 429,
    super.originalError,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'The service is temporarily unavailable. Please try again.',
    super.developerMessage,
    super.statusCode,
    super.originalError,
  });
}

class CancelledRequestException extends AppException {
  const CancelledRequestException({
    super.message = 'The request was cancelled.',
    super.developerMessage,
    super.originalError,
  });
}

class InvalidResponseException extends AppException {
  const InvalidResponseException({
    super.message = 'The service returned an unexpected response.',
    super.developerMessage,
    super.statusCode,
    super.originalError,
  });
}

class UnknownAppException extends AppException {
  const UnknownAppException({
    super.message = 'Something went wrong. Please try again.',
    super.developerMessage,
    super.statusCode,
    super.originalError,
  });
}
