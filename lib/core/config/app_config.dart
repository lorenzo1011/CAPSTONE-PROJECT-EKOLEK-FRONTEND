enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.enableNetworkLogs,
    required this.authRefreshPath,
    required this.tokenExpirationLeeway,
  });

  factory AppConfig({
    String environment = 'development',
    String apiBaseUrl = 'http://192.168.1.5:8000/api/',
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 20),
    Duration sendTimeout = const Duration(seconds: 20),
    bool enableNetworkLogs = true,
    String authRefreshPath = 'auth/token/refresh/',
    Duration tokenExpirationLeeway = const Duration(seconds: 30),
  }) {
    final parsedEnvironment = AppEnvironment.values.firstWhere(
      (value) => value.name == environment.toLowerCase(),
      orElse: () => throw ArgumentError.value(
        environment,
        'environment',
        'Must be development, staging, or production.',
      ),
    );
    final normalizedUrl = apiBaseUrl.trim();
    final uri = Uri.tryParse(normalizedUrl);
    if (normalizedUrl.isEmpty) {
      throw ArgumentError.value(apiBaseUrl, 'apiBaseUrl', 'Must not be empty.');
    }
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError.value(
        apiBaseUrl,
        'apiBaseUrl',
        'Must be an absolute URL.',
      );
    }
    if (!normalizedUrl.endsWith('/')) {
      throw ArgumentError.value(
        apiBaseUrl,
        'apiBaseUrl',
        'Must end with a forward slash.',
      );
    }
    if (parsedEnvironment == AppEnvironment.production &&
        uri.scheme.toLowerCase() != 'https') {
      throw ArgumentError.value(
        apiBaseUrl,
        'apiBaseUrl',
        'Production API URLs must use HTTPS.',
      );
    }
    if (connectTimeout <= Duration.zero ||
        receiveTimeout <= Duration.zero ||
        sendTimeout <= Duration.zero) {
      throw ArgumentError('Network timeouts must be greater than zero.');
    }
    final normalizedRefreshPath = authRefreshPath.trim();
    final refreshUri = Uri.tryParse(normalizedRefreshPath);
    if (normalizedRefreshPath.isNotEmpty &&
        (refreshUri == null ||
            refreshUri.hasScheme ||
            refreshUri.hasAuthority ||
            normalizedRefreshPath.startsWith('/'))) {
      throw ArgumentError.value(
        authRefreshPath,
        'authRefreshPath',
        'Must be a relative path within the configured API base URL.',
      );
    }
    if (tokenExpirationLeeway.isNegative) {
      throw ArgumentError.value(
        tokenExpirationLeeway,
        'tokenExpirationLeeway',
        'Must not be negative.',
      );
    }

    return AppConfig._(
      environment: parsedEnvironment,
      apiBaseUrl: normalizedUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      enableNetworkLogs:
          enableNetworkLogs && parsedEnvironment != AppEnvironment.production,
      authRefreshPath: normalizedRefreshPath,
      tokenExpirationLeeway: tokenExpirationLeeway,
    );
  }

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      environment: const String.fromEnvironment(
        'APP_ENV',
        defaultValue: 'development',
      ),
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://192.168.1.5:8000/api/',
      ),
      connectTimeout: Duration(
        seconds: const int.fromEnvironment(
          'API_CONNECT_TIMEOUT_SECONDS',
          defaultValue: 15,
        ),
      ),
      receiveTimeout: Duration(
        seconds: const int.fromEnvironment(
          'API_RECEIVE_TIMEOUT_SECONDS',
          defaultValue: 20,
        ),
      ),
      sendTimeout: Duration(
        seconds: const int.fromEnvironment(
          'API_SEND_TIMEOUT_SECONDS',
          defaultValue: 20,
        ),
      ),
      enableNetworkLogs: const bool.fromEnvironment(
        'ENABLE_NETWORK_LOGS',
        defaultValue: true,
      ),
      authRefreshPath: const String.fromEnvironment(
        'AUTH_REFRESH_PATH',
        defaultValue: 'auth/token/refresh/',
      ),
      tokenExpirationLeeway: Duration(
        seconds: const int.fromEnvironment(
          'TOKEN_EXPIRATION_LEEWAY_SECONDS',
          defaultValue: 30,
        ),
      ),
    );
  }

  final AppEnvironment environment;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableNetworkLogs;
  final String authRefreshPath;
  final Duration tokenExpirationLeeway;

  bool get isProduction => environment == AppEnvironment.production;
}
