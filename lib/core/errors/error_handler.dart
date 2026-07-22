import 'package:dio/dio.dart';

import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handle(Object error) {
    if (error is AppException) return error;
    if (error is DioException && error.error is AppException) {
      return error.error! as AppException;
    }
    if (error is! DioException) {
      return UnknownAppException(
        developerMessage: 'Unexpected application error: ${error.runtimeType}',
        originalError: error,
      );
    }

    final developerMessage =
        'Dio ${error.type.name}; status ${error.response?.statusCode ?? 'none'}';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return RequestTimeoutException(
          developerMessage: developerMessage,
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.cancel:
        return CancelledRequestException(
          developerMessage: developerMessage,
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          developerMessage: developerMessage,
          originalError: error,
        );
      case DioExceptionType.badResponse:
        return _fromResponse(error, developerMessage);
      case DioExceptionType.badCertificate:
        return NetworkException(
          developerMessage: developerMessage,
          originalError: error,
        );
      case DioExceptionType.unknown:
        return UnknownAppException(
          developerMessage: developerMessage,
          originalError: error,
        );
    }
  }

  static AppException _fromResponse(
    DioException error,
    String developerMessage,
  ) {
    final statusCode = error.response?.statusCode;
    if (statusCode == null) {
      return InvalidResponseException(
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode == 400 || statusCode == 422) {
      return ValidationException(
        statusCode: statusCode,
        fieldErrors: parseFieldErrors(error.response?.data),
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode == 401) {
      return UnauthorizedException(
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode == 403) {
      return ForbiddenException(
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode == 404) {
      return NotFoundException(
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode == 408) {
      return RequestTimeoutException(
        statusCode: statusCode,
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode == 409) {
      return ConflictException(
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode == 429) {
      return RateLimitException(
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    if (statusCode >= 500) {
      return ServerException(
        statusCode: statusCode,
        developerMessage: developerMessage,
        originalError: error,
      );
    }
    return InvalidResponseException(
      statusCode: statusCode,
      developerMessage: developerMessage,
      originalError: error,
    );
  }

  static Map<String, List<String>> parseFieldErrors(Object? data) {
    if (data is! Map) return const {};
    final nestedErrors = data['errors'];
    if (nestedErrors is Map) return parseFieldErrors(nestedErrors);
    final errors = <String, List<String>>{};
    data.forEach((key, value) {
      final messages = _safeMessages(value);
      if (messages.isNotEmpty) errors[key.toString()] = messages;
    });
    return errors;
  }

  static List<String> _safeMessages(Object? value) {
    if (value is String) return [_safeValidationMessage(value)];
    if (value is List) {
      return value
          .whereType<String>()
          .map(_safeValidationMessage)
          .toList(growable: false);
    }
    if (value is Map) {
      return value.values.expand(_safeMessages).toList(growable: false);
    }
    return const [];
  }

  static String _safeValidationMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 240 || trimmed.contains('<html')) {
      return 'This value is invalid.';
    }
    return trimmed;
  }
}
