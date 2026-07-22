import 'recyclable_material.dart';

class CollectionItem {
  const CollectionItem({
    required this.id,
    required this.material,
    required this.weightKg,
    required this.pointsPerKg,
    required this.awardedPoints,
  });
  factory CollectionItem.fromJson(Map<String, Object?> j) => CollectionItem(
    id: j['id'] as int,
    material: RecyclableMaterial.fromJson(
      (j['material'] as Map).map((k, v) => MapEntry(k.toString(), v)),
    ),
    weightKg: j['weight_kg'] as String,
    pointsPerKg: j['points_per_kg'] as int?,
    awardedPoints: j['computed_points'] as int,
  );
  final int id, awardedPoints;
  final RecyclableMaterial material;
  final String weightKg;
  final int? pointsPerKg;
}
