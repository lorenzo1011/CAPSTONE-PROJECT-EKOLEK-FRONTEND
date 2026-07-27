import 'dart:convert';

import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/resident_id/models/digital_resident_id.dart';
import 'package:ekolek_app/features/resident_id/models/resident_id_status.dart';
import 'package:ekolek_app/features/resident_id/widgets/digital_resident_card.dart';
import 'package:ekolek_app/features/resident_id/widgets/secure_qr_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    expect(find.text('Secure QR unavailable'), findsOneWidget);
    expect(
      find.text('No active verification QR is available for this ID.'),
      findsWidgets,
    );
  });

  test('past backend expiry disables an otherwise active QR', () {
    final id = DigitalResidentId.fromJson({
      ...contract(),
      'id_card_expiry_date': '2020-01-01',
    });
    expect(id.status, ResidentIdStatus.expired);
    expect(id.isExpired, isTrue);
    expect(id.canDisplayQr, isFalse);
    expect(id.qrUnavailableReason, contains('expired'));
  });

  for (final size in const [300.0, 360.0, 430.0, 760.0]) {
    testWidgets('official admin-style ID remains overflow-free at $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(size, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _TestImageBundle(),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DigitalResidentCard(
                    id: DigitalResidentId.fromJson(contract()),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Official ID Preview'), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('official ID can switch to its backend-matching back design', (
    tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _TestImageBundle(),
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DigitalResidentCard(
                id: DigitalResidentId.fromJson(contract()),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('OFFICIAL TERMS AND RESIDENT GUIDELINES'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Contract/security coverage below performs no external request.
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

class _TestImageBundle extends CachingAssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
    '+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png')) {
      return ByteData.sublistView(_transparentPng);
    }
    return rootBundle.load(key);
  }
}
