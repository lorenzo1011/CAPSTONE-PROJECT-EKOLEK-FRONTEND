import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/profile/models/profile_field_permissions.dart';
import 'package:ekolek_app/features/profile/models/profile_update_request.dart';
import 'package:ekolek_app/features/profile/models/resident_profile.dart';
import 'package:flutter_test/flutter_test.dart';

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
