import 'package:ekolek_app/core/api/api_client.dart';
import 'package:ekolek_app/core/auth/auth_session_manager.dart';
import 'package:ekolek_app/core/auth/auth_tokens.dart';
import 'package:ekolek_app/core/auth/session_expired_handler.dart';
import 'package:ekolek_app/core/config/app_config.dart';
import 'package:ekolek_app/core/storage/token_storage.dart';
import 'package:ekolek_app/features/auth/models/auth_user.dart';
import 'package:ekolek_app/features/auth/providers/auth_controller.dart';
import 'package:ekolek_app/features/auth/services/auth_service.dart';

class AuthTestHarness {
  AuthTestHarness({AuthUser? user, bool hasSession = true}) {
    storage = TestTokenStorage(hasSession ? _validTokens() : null);
    sessionManager = AuthSessionManager(tokenStorage: storage);
    expiredHandler = SessionExpiredHandler();
    service = TestAuthService(
      user:
          user ??
          const AuthUser(
            id: 1,
            email: 'resident@example.test',
            role: UserRole.resident,
            approvalStatus: ResidentApprovalStatus.approved,
            residentProfileId: 1,
          ),
    );
    controller = AuthController(
      authService: service,
      sessionManager: sessionManager,
      sessionExpiredHandler: expiredHandler,
    );
  }

  late final TestTokenStorage storage;
  late final AuthSessionManager sessionManager;
  late final SessionExpiredHandler expiredHandler;
  late final TestAuthService service;
  late final AuthController controller;

  static AuthTokens _validTokens() => AuthTokens(
    accessToken: 'test-access',
    refreshToken: 'test-refresh',
    accessTokenExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    refreshTokenExpiresAt: DateTime.now().toUtc().add(const Duration(days: 1)),
  );

  Future<void> dispose() async {
    await sessionManager.dispose();
    await expiredHandler.dispose();
  }
}

class TestTokenStorage implements TokenStorage {
  TestTokenStorage([this.tokens]);
  AuthTokens? tokens;

  @override
  Future<void> clearTokens() async => tokens = null;
  @override
  Future<bool> hasTokens() async => tokens != null;
  @override
  Future<String?> readAccessToken() async => tokens?.accessToken;
  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;
  @override
  Future<AuthTokens?> readTokens() async => tokens;
  @override
  Future<void> saveTokens(AuthTokens value) async => tokens = value;
}

class TestAuthService extends AuthService {
  TestAuthService({required this.user})
    : super(apiClient: ApiClient(config: AppConfig(enableNetworkLogs: false)));

  final AuthUser user;

  @override
  Future<AuthUser> getCurrentUser({cancelToken}) async => user;
}
