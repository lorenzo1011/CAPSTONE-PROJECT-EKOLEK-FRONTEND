import 'package:ekolek_app/app/theme/app_theme.dart';
import 'package:ekolek_app/core/api/api_client.dart';
import 'package:ekolek_app/core/config/app_config.dart';
import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/achievements/models/achievement_summary.dart';
import 'package:ekolek_app/features/achievements/providers/achievements_controller.dart';
import 'package:ekolek_app/features/achievements/providers/achievements_state.dart';
import 'package:ekolek_app/features/achievements/services/achievements_service.dart';
import 'package:ekolek_app/features/auth/models/auth_user.dart';
import 'package:ekolek_app/features/home/models/home_dashboard_data.dart';
import 'package:ekolek_app/features/home/providers/home_controller.dart';
import 'package:ekolek_app/features/home/providers/home_state.dart';
import 'package:ekolek_app/features/profile/models/profile_field_permissions.dart';
import 'package:ekolek_app/features/profile/models/profile_update_request.dart';
import 'package:ekolek_app/features/profile/models/resident_profile.dart';
import 'package:ekolek_app/features/profile/providers/profile_controller.dart';
import 'package:ekolek_app/features/profile/providers/profile_state.dart';
import 'package:ekolek_app/features/profile/screens/profile_screen.dart';
import 'package:ekolek_app/features/profile/services/profile_service.dart';
import 'package:ekolek_app/features/wallet/models/wallet_summary.dart';
import 'package:ekolek_app/features/wallet/services/wallet_service.dart';
import 'package:ekolek_app/shared/providers/achievements_providers.dart';
import 'package:ekolek_app/shared/providers/auth_providers.dart';
import 'package:ekolek_app/shared/providers/home_providers.dart';
import 'package:ekolek_app/shared/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_harness.dart';

void main() {
  group('resident profile contract', () {
    test('uses the verified mobile endpoint', () {
      expect(ApiEndpoints.profile, 'mobile/profile/');
    });

    test('parses only resident-safe profile information', () {
      final profile = ResidentProfile.fromJson(_profileJson);

      expect(profile.fullName, 'Juan Dela Cruz');
      expect(profile.phoneNumber, '09171234567');
      expect(profile.barangay.name, 'San Isidro');
      expect(profile.permissions.canEditPhone, isTrue);
      expect(profile.permissions.canEditPhoto, isTrue);
      expect(profile.idCard?.number, 'RID-001');
      expect(profile.toString(), isNot(contains('juan@example.com')));
      expect(profile.toString(), isNot(contains('09171234567')));
      expect(profile.toString(), isNot(contains('Sample Street')));
    });

    test('self-service request cannot contain protected fields', () {
      final json = const ProfileUpdateRequest(
        phoneNumber: ' 09170000000 ',
      ).toJson();

      expect(json, {'phone_number': '09170000000'});
      expect(json, isNot(contains('email')));
      expect(json, isNot(contains('full_name')));
      expect(json, isNot(contains('complete_address')));
      expect(json, isNot(contains('resident_id')));
    });

    test('missing permissions disable editing safely', () {
      final permissions = ProfileFieldPermissions.fromJson(null);
      expect(permissions.canEditPhone, isFalse);
      expect(permissions.canEditPhoto, isFalse);
    });
  });

  testWidgets(
    'profile reference layout is responsive and uses live resident metrics',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(273, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = AuthTestHarness(
        user: const AuthUser(
          id: 1,
          email: 'resident.test@ekolek.local',
          fullName: 'Juan Dela Cruz',
          role: UserRole.resident,
          approvalStatus: ResidentApprovalStatus.approved,
          residentProfileId: 1,
        ),
      );
      await auth.controller.initialize();
      addTearDown(auth.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => auth.controller),
            profileControllerProvider.overrideWith(
              (ref) => _StaticProfileController(),
            ),
            homeControllerProvider.overrideWith(
              (ref) => _StaticHomeController(),
            ),
            achievementsControllerProvider.overrideWith(
              (ref) => _StaticAchievementsController(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(find.text('Approved Resident'), findsOneWidget);
      expect(find.text('320'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('About E-KOLEK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

ApiClient _testClient() =>
    ApiClient(config: AppConfig(enableNetworkLogs: false));

class _StaticProfileController extends ProfileController {
  _StaticProfileController() : super(ProfileService(_testClient())) {
    state = ProfileState(
      phase: ProfilePhase.loaded,
      profile: ResidentProfile.fromJson(_profileJson),
    );
  }

  @override
  Future<void> load({bool refresh = false}) async {}
}

class _StaticHomeController extends HomeController {
  _StaticHomeController() : super(WalletService(_testClient())) {
    state = HomeState(
      phase: HomePhase.loaded,
      data: HomeDashboardData(
        userId: 1,
        displayName: 'Juan Dela Cruz',
        wallet: const WalletSummary(
          id: 1,
          currentBalance: 320,
          lifetimeEarned: 1450,
          lifetimeRedeemed: 230,
          lifetimeAdjusted: 0,
        ),
        transactions: const [],
        refreshedAt: DateTime.utc(2026, 7, 27),
      ),
    );
  }

  @override
  Future<bool> load(AuthUser user, {bool refresh = false}) async => true;
}

class _StaticAchievementsController extends AchievementsController {
  _StaticAchievementsController() : super(AchievementsService(_testClient())) {
    state = const AchievementsState(
      phase: AchievementsPhase.loaded,
      summary: AchievementSummary(
        totalVisible: 8,
        totalUnlocked: 4,
        totalLocked: 4,
        completionPercentage: 50,
        badgesByType: {},
      ),
    );
  }

  @override
  Future<void> load({bool refresh = false}) async {}
}

final Map<String, Object?> _profileJson = {
  'email': 'juan@example.com',
  'phone_number': '09171234567',
  'full_name': 'Juan Dela Cruz',
  'birthdate': '1995-02-03',
  'barangay': {'name': 'San Isidro', 'district_or_area': 'District 1'},
  'complete_address': '12 Sample Street',
  'profile_photo': null,
  'resident_id': 'RES-001',
  'approval_status': 'APPROVED',
  'approved_at': '2026-01-02T08:00:00Z',
  'member_since': '2025-10-01T08:00:00Z',
  'id_card': {
    'card_number': 'RID-001',
    'status': 'ACTIVE',
    'issued_at': '2026-01-02T08:00:00Z',
    'expiry_date': '2027-01-02',
  },
  'editable_fields': ['phone_number', 'profile_photo'],
  'updated_at': '2026-07-22T08:00:00Z',
};
