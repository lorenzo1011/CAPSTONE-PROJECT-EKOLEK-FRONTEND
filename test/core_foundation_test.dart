import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ekolek_app/app/app.dart';
import 'package:ekolek_app/app/app_routes.dart';
import 'package:ekolek_app/app/router.dart';
import 'package:ekolek_app/core/api/api_client.dart';
import 'package:ekolek_app/core/api/network_log_interceptor.dart';
import 'package:ekolek_app/core/config/app_config.dart';
import 'package:ekolek_app/core/errors/app_exception.dart';
import 'package:ekolek_app/core/errors/error_handler.dart';
import 'package:ekolek_app/core/services/connectivity_service.dart';
import 'package:ekolek_app/core/widgets/app_error_view.dart';
import 'package:ekolek_app/core/widgets/app_loading_view.dart';
import 'package:ekolek_app/core/widgets/app_offline_view.dart';
import 'package:ekolek_app/core/widgets/app_skeleton.dart';
import 'package:ekolek_app/shared/providers/core_providers.dart';
import 'package:ekolek_app/shared/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  group('AppConfig', () {
    test('accepts a valid development base URL', () {
      final config = AppConfig(
        environment: 'development',
        apiBaseUrl: 'http://10.0.2.2:8000/api/',
      );
      expect(config.apiBaseUrl, 'http://10.0.2.2:8000/api/');
    });

    test('rejects an empty API base URL', () {
      expect(() => AppConfig(apiBaseUrl: ''), throwsArgumentError);
    });

    test('rejects a non-HTTPS production API URL', () {
      expect(
        () => AppConfig(
          environment: 'production',
          apiBaseUrl: 'http://example.com/api/',
        ),
        throwsArgumentError,
      );
    });
  });

  group('ErrorHandler', () {
    DioException responseError(int statusCode, {Object? data}) {
      final request = RequestOptions(path: '/test');
      return DioException.badResponse(
        statusCode: statusCode,
        requestOptions: request,
        response: Response<Object?>(
          requestOptions: request,
          statusCode: statusCode,
          data: data,
        ),
      );
    }

    test('maps HTTP 400 to ValidationException', () {
      final exception = ErrorHandler.handle(
        responseError(
          400,
          data: {
            'email': ['Invalid email.'],
          },
        ),
      );
      expect(exception, isA<ValidationException>());
      expect(exception.fieldErrors['email'], ['Invalid email.']);
    });

    test('maps HTTP 401 to UnauthorizedException', () {
      expect(
        ErrorHandler.handle(responseError(401)),
        isA<UnauthorizedException>(),
      );
    });

    test('maps HTTP 403 to ForbiddenException', () {
      expect(
        ErrorHandler.handle(responseError(403)),
        isA<ForbiddenException>(),
      );
    });

    test('maps HTTP 404 to NotFoundException', () {
      expect(ErrorHandler.handle(responseError(404)), isA<NotFoundException>());
    });

    test('maps server errors to ServerException', () {
      expect(ErrorHandler.handle(responseError(503)), isA<ServerException>());
    });

    test('maps timeout errors correctly', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(ErrorHandler.handle(error), isA<RequestTimeoutException>());
    });

    test('maps cancelled requests correctly', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );
      expect(ErrorHandler.handle(error), isA<CancelledRequestException>());
    });
  });

  group('ApiClient', () {
    final config = AppConfig(
      apiBaseUrl: 'http://10.0.2.2:8000/api/',
      enableNetworkLogs: false,
    );

    test('uses the configured base URL', () {
      expect(ApiClient(config: config).dio.options.baseUrl, config.apiBaseUrl);
    });

    test('applies expected default headers', () {
      final options = ApiClient(config: config).dio.options;
      expect(options.headers[Headers.acceptHeader], Headers.jsonContentType);
      expect(options.contentType, Headers.jsonContentType);
    });
  });

  test('development logger sanitizes sensitive values', () {
    final sanitized =
        NetworkLogInterceptor.sanitizeForLog({
              'email': 'resident@example.com',
              'password': 'private',
              'access_token': 'jwt',
              'profile_photo': [1, 2, 3],
            })!
            as Map<String, Object?>;

    expect(sanitized['email'], 'resident@example.com');
    expect(sanitized['password'], '[REDACTED]');
    expect(sanitized['access_token'], '[REDACTED]');
    expect(sanitized['profile_photo'], '[REDACTED]');
  });

  test('connectivity provider can be overridden', () async {
    final container = ProviderContainer(
      overrides: [
        connectivityStatusProvider.overrideWithValue(
          const AsyncData(ConnectivityStatus.offline),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(connectivityStatusProvider).requireValue,
      ConnectivityStatus.offline,
    );
  });

  group('foundation widgets', () {
    testWidgets('loading view supports a custom message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppLoadingView(message: 'Loading activity')),
      );
      expect(find.text('Loading activity'), findsOneWidget);
    });

    testWidgets('error view triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: AppErrorView(
            title: 'Unable to load',
            message: 'Please try again.',
            retryLabel: 'Retry',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('offline view triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(home: AppOfflineView(onRetry: () => retried = true)),
      );
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('skeleton renders without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppSkeleton(width: 160, height: 24)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AppSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('offline banner', () {
    testWidgets('displays offline and disappears online', (tester) async {
      final controller = StreamController<ConnectivityStatus>();
      final auth = AuthTestHarness();
      final router = createAppRouter(authController: auth.controller);
      addTearDown(auth.dispose);
      addTearDown(controller.close);
      addTearDown(router.dispose);
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => auth.controller),
            connectivityStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: EkolekApp(router: router),
        ),
      );
      router.goNamed(AppRoutes.home);
      controller.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'You appear to be offline. Some features may be unavailable.',
        ),
        findsOneWidget,
      );

      controller.add(ConnectivityStatus.online);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'You appear to be offline. Some features may be unavailable.',
        ),
        findsNothing,
      );
    });

    testWidgets('large text does not overflow the offline banner', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final auth = AuthTestHarness();
      final router = createAppRouter(authController: auth.controller);
      addTearDown(auth.dispose);
      addTearDown(router.dispose);
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => auth.controller),
            connectivityStatusProvider.overrideWith(
              (ref) => Stream.value(ConnectivityStatus.offline),
            ),
          ],
          child: EkolekApp(router: router),
        ),
      );
      router.goNamed(AppRoutes.home);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
