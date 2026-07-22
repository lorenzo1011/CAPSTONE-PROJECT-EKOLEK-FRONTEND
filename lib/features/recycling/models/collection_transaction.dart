import 'collection_item.dart';

enum CollectionStatus { completed, adjusted, voided, unknown }

class CollectionTransaction {
  const CollectionTransaction({
    required this.id,
    required this.number,
    required this.status,
    required this.totalWeightKg,
    required this.totalPoints,
    required this.processedAt,
    required this.items,
    this.eventTitle,
    this.barangayName,
  });
  factory CollectionTransaction.fromJson(Map<String, Object?> j) {
    final event = j['collection_event'],
        barangay = j['barangay'],
        rawItems = j['items'];
    return CollectionTransaction(
      id: j['id'] as int,
      number: j['transaction_number'] as String,
      status: switch (j['status']) {
        'COMPLETED' => CollectionStatus.completed,
        'ADJUSTED' => CollectionStatus.adjusted,
        'VOIDED' => CollectionStatus.voided,
        _ => CollectionStatus.unknown,
      },
      totalWeightKg: j['total_weight_kg'] as String,
      totalPoints: j['total_points_earned'] as int,
      processedAt: DateTime.parse(j['processed_at'] as String).toUtc(),
      eventTitle: event is Map && event['title'] is String
          ? event['title']! as String
          : null,
      barangayName: barangay is Map && barangay['name'] is String
          ? barangay['name']! as String
          : null,
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (e) => CollectionItem.fromJson(
                    e.map((k, v) => MapEntry(k.toString(), v)),
                  ),
                )
                .toList()
          : const [],
    );
  }
  final int id, totalPoints;
  final String number, totalWeightKg;
  final CollectionStatus status;
  final DateTime processedAt;
  final String? eventTitle, barangayName;
  final List<CollectionItem> items;
}
