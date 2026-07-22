class RecyclableMaterial {
  const RecyclableMaterial({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    this.description = '',
    this.currentPointsPerKg,
  });
  factory RecyclableMaterial.fromJson(Map<String, Object?> j) =>
      RecyclableMaterial(
        id: j['id'] as int,
        name: j['name'] as String,
        category: j['category'] is String ? j['category']! as String : '',
        unit: j['unit_type'] is String ? j['unit_type']! as String : 'KG',
        description: j['description'] is String
            ? j['description']! as String
            : '',
        currentPointsPerKg: j['current_points_per_kg'] as int?,
      );
  final int id;
  final String name, category, unit, description;
  final int? currentPointsPerKg;
}
