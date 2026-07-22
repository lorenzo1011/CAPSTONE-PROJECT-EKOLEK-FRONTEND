import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ekolek_app/core/api/api_client.dart';
import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/core/config/app_config.dart';
import 'package:ekolek_app/core/storage/resident_status_storage.dart';
import 'package:ekolek_app/features/auth/models/account_status_info.dart';
import 'package:ekolek_app/features/auth/models/auth_user.dart';
import 'package:ekolek_app/features/auth/models/resident_account_status.dart';
import 'package:ekolek_app/features/auth/providers/account_status_controller.dart';
import 'package:ekolek_app/features/auth/services/account_status_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  test('backend status values map safely', () {
    expect(ResidentAccountStatus.fromBackend('PENDING').isPending, isTrue);
    expect(ResidentAccountStatus.fromBackend('APPROVED').isApproved, isTrue);
    expect(ResidentAccountStatus.fromBackend('REJECTED').isRejected, isTrue);
    expect(ResidentAccountStatus.fromBackend('SUSPENDED').isSuspended, isTrue);
    expect(
      ResidentAccountStatus.fromBackend('future-value'),
      ResidentAccountStatus.unknown,
    );
    expect(ResidentAccountStatus.unknown.canAccessResidentApp, isFalse);
  });

  test('status service uses authenticated current-user endpoint', () async {
    final adapter = _StatusAdapter();
    final client = ApiClient(config: AppConfig(enableNetworkLogs: false));
    client.dio.httpClientAdapter = adapter;
    final result = await AccountStatusService(
      apiClient: client,
    ).getCurrentStatus();
    expect(adapter.options?.path, ApiEndpoints.currentUser);
    expect(adapter.options?.extra['requiresAuthentication'], isTrue);
    expect(result.status, ResidentAccountStatus.pending);
    expect(result.userId, 7);
    client.dio.close(force: true);
  });

  test('refresh prevents duplicate requests and detects approval', () async {
    final auth = AuthTestHarness(user: _user(ResidentApprovalStatus.pending));
    await auth.controller.initialize();
    final storage = _MemoryStatusStorage()
      ..values[7] = ResidentStatusMetadata(
        status: 'PENDING',
        verifiedAt: DateTime.utc(2026),
        welcomeCompleted: false,
      );
    final completer = Completer<AccountStatusInfo>();
    final service = _FakeStatusService(completer.future);
    final controller = AccountStatusController(
      service: service,
      storage: storage,
      authController: auth.controller,
    );
    final first = controller.refresh(manual: true);
    final second = controller.refresh(manual: true);
    expect(identical(first, second), isTrue);
    completer.complete(_info(ResidentAccountStatus.approved));
    expect(await first, isTrue);
    expect(service.calls, 1);
    expect(controller.state.approvalTransitionDetected, isTrue);
    expect(auth.controller.state.approvedWelcomeRequired, isTrue);
    controller.dispose();
    await auth.dispose();
  });

  test('welcome completion is scoped to the verified resident', () async {
    final auth = AuthTestHarness(user: _user(ResidentApprovalStatus.approved));
    await auth.controller.initialize();
    final storage = _MemoryStatusStorage();
    final controller = AccountStatusController(
      service: _FakeStatusService(
        Future.value(_info(ResidentAccountStatus.approved)),
      ),
      storage: storage,
      authController: auth.controller,
    );
    await controller.refresh();
    await controller.completeWelcome();
    expect(storage.values[7]?.welcomeCompleted, isTrue);
    expect(storage.values[8], isNull);
    controller.dispose();
    await auth.dispose();
  });
}

AuthUser _user(ResidentApprovalStatus status) => AuthUser(
  id: 7,
  email: 'resident@example.test',
  role: UserRole.resident,
  approvalStatus: status,
  residentProfileId: 11,
);

AccountStatusInfo _info(ResidentAccountStatus status) => AccountStatusInfo(
  userId: 7,
  profileId: 11,
  status: status,
  displayName: 'Verified Resident',
);

class _FakeStatusService extends AccountStatusService {
  _FakeStatusService(this.result)
    : super(apiClient: ApiClient(config: AppConfig(enableNetworkLogs: false)));
  final Future<AccountStatusInfo> result;
  int calls = 0;
  @override
  Future<AccountStatusInfo> getCurrentStatus({CancelToken? cancelToken}) {
    calls++;
    return result;
  }
}

class _MemoryStatusStorage implements ResidentStatusStorage {
  final values = <int, ResidentStatusMetadata>{};
  @override
  Future<void> clear(int userId) async => values.remove(userId);
  @override
  Future<void> markWelcomeCompleted(int userId) async {
    final value = values[userId];
    if (value != null) {
      values[userId] = ResidentStatusMetadata(
        status: value.status,
        verifiedAt: value.verifiedAt,
        welcomeCompleted: true,
      );
    }
  }

  @override
  Future<ResidentStatusMetadata?> read(int userId) async => values[userId];
  @override
  Future<void> writeStatus(
    int userId,
    String status,
    DateTime verifiedAt,
  ) async {
    values[userId] = ResidentStatusMetadata(
      status: status,
      verifiedAt: verifiedAt,
      welcomeCompleted: values[userId]?.welcomeCompleted ?? false,
    );
  }
}

class _StatusAdapter implements HttpClientAdapter {
  RequestOptions? options;
  @override
  Future<ResponseBody> fetch(
    RequestOptions requestOptions,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    options = requestOptions;
    return ResponseBody.fromString(
      '{"success":true,"data":{"user":{"id":7},"resident":{"id":11,"full_name":"Verified Resident","approval_status":"PENDING","created_at":"2026-07-15T00:00:00Z"}}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
