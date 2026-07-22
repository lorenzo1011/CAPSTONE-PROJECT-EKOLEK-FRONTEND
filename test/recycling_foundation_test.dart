import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/core/utils/formatters.dart';
import 'package:ekolek_app/features/recycling/models/collection_item.dart';
import 'package:ekolek_app/features/recycling/models/collection_transaction.dart';
import 'package:ekolek_app/features/recycling/models/recyclable_material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Recycling foundation — 56 contract cases', () {
    final statuses = <String, CollectionStatus>{
      'COMPLETED': CollectionStatus.completed,
      'ADJUSTED': CollectionStatus.adjusted,
      'VOIDED': CollectionStatus.voided,
      'UNKNOWN': CollectionStatus.unknown,
    };
    for (final entry in statuses.entries) {
      test('maps verified collection status ${entry.key}', () {
        expect(_transaction(status: entry.key).status, entry.value);
      });
    }

    const weights = [
      '0.000',
      '0.125',
      '1.000',
      '1.250',
      '10.500',
      '999999.999',
    ];
    for (final weight in weights) {
      test('preserves backend decimal weight $weight', () {
        expect(_transaction(weight: weight).totalWeightKg, weight);
      });
      test('formats backend decimal weight $weight safely', () {
        expect(AppFormatters.weight(weight), endsWith(' kg'));
      });
    }

    for (var index = 0; index < 10; index++) {
      test('parses resident material case ${index + 1}', () {
        final material = RecyclableMaterial.fromJson(_material(index));
        expect(material.id, index + 1);
        expect(material.currentPointsPerKg, index * 5);
        expect(material.unit, 'KG');
      });
    }

    for (var index = 0; index < 10; index++) {
      test('preserves transaction-time item rate case ${index + 1}', () {
        final item = CollectionItem.fromJson(_item(index));
        expect(item.pointsPerKg, 10 + index);
        expect(item.awardedPoints, 20 + index);
        expect(item.weightKg, '2.000');
      });
    }

    for (var index = 0; index < 12; index++) {
      test('parses resident collection safely case ${index + 1}', () {
        final transaction = _transaction(id: index + 1, points: index * 100);
        expect(transaction.id, index + 1);
        expect(transaction.totalPoints, index * 100);
        expect(transaction.items, hasLength(2));
        expect(transaction.processedAt.isUtc, isTrue);
      });
    }

    test('history endpoint is resident mobile endpoint', () {
      expect(ApiEndpoints.recycling, 'mobile/recycling/');
    });
    test('detail endpoint contains only the stable collection id', () {
      expect(ApiEndpoints.recyclingDetail(42), 'mobile/recycling/42/');
    });
    test('materials endpoint is resident mobile endpoint', () {
      expect(ApiEndpoints.materials, 'mobile/materials/');
    });
    test('resident endpoints never use admin or EkoScan paths', () {
      expect(
        '${ApiEndpoints.recycling}${ApiEndpoints.materials}',
        isNot(contains('admin')),
      );
      expect(
        '${ApiEndpoints.recycling}${ApiEndpoints.materials}',
        isNot(contains('ekoscan')),
      );
    });
    test('backend-awarded points remain authoritative', () {
      expect(
        CollectionItem.fromJson({
          ..._item(0),
          'computed_points': 99,
        }).awardedPoints,
        99,
      );
    });
    test('current material rate does not replace historical item rate', () {
      final item = CollectionItem.fromJson({
        ..._item(0),
        'points_per_kg': 7,
        'material': {..._material(0), 'current_points_per_kg': 50},
      });
      expect(item.pointsPerKg, 7);
      expect(item.material.currentPointsPerKg, 50);
    });
    test('missing optional event and barangay parse safely', () {
      final transaction = CollectionTransaction.fromJson({
        ..._transactionJson(),
        'collection_event': null,
        'barangay': null,
      });
      expect(transaction.eventTitle, isNull);
      expect(transaction.barangayName, isNull);
    });
    test('collection number is preserved without client invention', () {
      expect(_transaction().number, 'COL-2026-000001');
    });
  });
}

Map<String, Object?> _material(int index) => {
  'id': index + 1,
  'name': 'Material $index',
  'description': '',
  'category': 'Recyclable',
  'unit_type': 'KG',
  'current_points_per_kg': index * 5,
};

Map<String, Object?> _item(int index) => {
  'id': index + 1,
  'material': _material(index),
  'weight_kg': '2.000',
  'points_per_kg': 10 + index,
  'computed_points': 20 + index,
};

CollectionTransaction _transaction({
  int id = 1,
  int points = 20,
  String status = 'COMPLETED',
  String weight = '2.000',
}) => CollectionTransaction.fromJson(
  _transactionJson(id: id, points: points, status: status, weight: weight),
);

Map<String, Object?> _transactionJson({
  int id = 1,
  int points = 20,
  String status = 'COMPLETED',
  String weight = '2.000',
}) => {
  'id': id,
  'transaction_number': 'COL-2026-000001',
  'collection_event': {'id': 1, 'title': 'Collection'},
  'barangay': {'id': 1, 'name': 'Barangay'},
  'total_weight_kg': weight,
  'total_points_earned': points,
  'status': status,
  'processed_at': '2026-07-15T08:00:00Z',
  'items': [_item(0), _item(1)],
};
