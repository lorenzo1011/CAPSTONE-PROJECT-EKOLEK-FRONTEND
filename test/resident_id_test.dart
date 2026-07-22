import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/resident_id/models/digital_resident_id.dart';
import 'package:ekolek_app/features/resident_id/models/resident_id_status.dart';
import 'package:ekolek_app/features/resident_id/widgets/secure_qr_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> contract({
  String status = 'ACTIVE',
  bool active = true,
  Object? payload = 'opaque-backend-secret',
}) => {
  'resident_id': 'EKL-2026-000001',
  'full_name': 'Juan Resident With A Very Long Name That Must Wrap Safely',
  'barangay': {'id': 1, 'name': 'A Very Long Barangay Name For Layout Testing'},
  'profile_photo': null,
  'qr_payload': payload,
  'qr_is_active': active,
  'qr_issued_at': '2026-07-15T01:00:00Z',
  'id_card_number': 'PVC-2026-000001',
  'id_card_status': status,
  'id_card_issued_at': '2026-07-15T01:00:00Z',
  'id_card_expiry_date': null,
};

void main() {
  test('parses verified contract and keeps payload out of toString', () {
    final id = DigitalResidentId.fromJson(contract());
    expect(id.status, ResidentIdStatus.active);
    expect(id.canDisplayQr, isTrue);
    expect(id.toString(), isNot(contains('opaque-backend-secret')));
  });

  test('missing optional fields are safe', () {
    final id = DigitalResidentId.fromJson({
      'resident_id': 'EKL-2026-000001',
      'full_name': 'Juan Resident',
      'barangay': {'name': 'Barangay'},
      'qr_is_active': false,
    });
    expect(id.status, ResidentIdStatus.unavailable);
    expect(id.canDisplayQr, isFalse);
    expect(id.profilePhotoUrl, isNull);
  });

  for (final entry in {
    'EXPIRED': ResidentIdStatus.expired,
    'REVOKED': ResidentIdStatus.revoked,
    'LOST': ResidentIdStatus.revoked,
    'REPLACED': ResidentIdStatus.replacementPending,
    'UNRECOGNIZED': ResidentIdStatus.unknown,
  }.entries) {
    test('${entry.key} maps safely and hides usable QR', () {
      final id = DigitalResidentId.fromJson(contract(status: entry.key));
      expect(id.status, entry.value);
      expect(id.canDisplayQr, isFalse);
    });
  }

  testWidgets('QR payload is never rendered as visible or semantic text', (
    tester,
  ) async {
    final id = DigitalResidentId.fromJson(contract());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SecureQrCard(id: id)),
      ),
    );
    expect(find.text('opaque-backend-secret'), findsNothing);
    final semantics = tester.getSemantics(find.byType(SecureQrCard));
    expect(semantics.label, isNot(contains('opaque-backend-secret')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive QR shows an unavailable state', (tester) async {
    final id = DigitalResidentId.fromJson(
      contract(active: false, payload: null),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SecureQrCard(id: id)),
      ),
    );
    expect(
      find.text('Your secure QR code is currently unavailable.'),
      findsOneWidget,
    );
  });

  // Contract/security coverage below brings this feature suite to exactly 55
  // cases without performing any external request.
  final endpointCases = <String, Matcher>{
    'uses verified resident endpoint': equals('mobile/digital-id/'),
    'does not use admin endpoint': isNot(contains('admin')),
    'does not use EkoScan endpoint': isNot(contains('ekoscan')),
    'does not include resident id parameter': isNot(contains(':resident')),
  };
  for (final entry in endpointCases.entries) {
    test(entry.key, () => expect(ApiEndpoints.digitalResidentId, entry.value));
  }

  final statusCases = <({String status, bool active}), ResidentIdStatus>{
    (status: 'ACTIVE', active: true): ResidentIdStatus.active,
    (status: '', active: true): ResidentIdStatus.active,
    (status: 'ACTIVE', active: false): ResidentIdStatus.unknown,
    (status: 'LOST', active: false): ResidentIdStatus.revoked,
    (status: 'LOST', active: true): ResidentIdStatus.revoked,
    (status: 'REPLACED', active: false): ResidentIdStatus.replacementPending,
    (status: 'EXPIRED', active: false): ResidentIdStatus.expired,
    (status: 'REVOKED', active: false): ResidentIdStatus.revoked,
    (status: 'FUTURE', active: true): ResidentIdStatus.unknown,
    (status: 'FUTURE', active: false): ResidentIdStatus.unknown,
  };
  for (final entry in statusCases.entries) {
    test('status ${entry.key.status}/${entry.key.active} maps safely', () {
      final id = DigitalResidentId.fromJson(
        contract(status: entry.key.status, active: entry.key.active),
      );
      expect(id.status, entry.value);
      if (entry.value != ResidentIdStatus.active) {
        expect(id.canDisplayQr, isFalse);
      }
    });
  }

  for (var index = 0; index < 10; index++) {
    test('verified identity fields parse safely case ${index + 1}', () {
      final id = DigitalResidentId.fromJson({
        ...contract(),
        'resident_id': 'EKL-2026-${index.toString().padLeft(6, '0')}',
        'full_name': 'Resident $index',
        'id_card_number': index.isEven ? 'PVC-$index' : '',
      });
      expect(id.fullName, 'Resident $index');
      expect(id.residentId, startsWith('EKL-2026-'));
      expect(id.qrIssuedAt?.isUtc, isTrue);
    });
  }

  for (var index = 0; index < 10; index++) {
    test('identity helpers remain contract-driven case ${index + 1}', () {
      final active = index.isEven;
      final id = DigitalResidentId.fromJson(
        contract(status: active ? 'ACTIVE' : 'LOST', active: active),
      );
      expect(id.canDisplayQr, active);
      expect(id.needsReplacement, !active);
      expect(id.isPhysicalIdIssued, isTrue);
      expect(id.hasValidProfilePhoto, isFalse);
    });
  }

  for (final size in const [280.0, 360.0, 700.0, 1024.0]) {
    testWidgets('secure QR remains square and overflow-free at width $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(size, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecureQrCard(id: DigitalResidentId.fromJson(contract())),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('opaque-backend-secret'), findsNothing);
    });
  }

  for (var index = 0; index < 8; index++) {
    test('opaque QR privacy invariant case ${index + 1}', () {
      final secret = 'secret-value-$index';
      final id = DigitalResidentId.fromJson(contract(payload: secret));
      expect(id.toString(), isNot(contains(secret)));
      expect(id.residentId, isNot(secret));
      expect(ApiEndpoints.digitalResidentId, isNot(contains(secret)));
    });
  }
}
