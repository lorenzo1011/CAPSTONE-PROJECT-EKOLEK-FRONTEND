import 'reward_availability.dart';
import 'reward_stock.dart';

class RewardItem {
  const RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pointsRequired,
    required this.availability,
    required this.stock,
    required this.minimumQuantity,
    required this.maximumQuantity,
    required this.requiresRewardEvent,
    this.imageUrl,
    this.updatedAt,
  });
  factory RewardItem.fromJson(Map<String, Object?> j) {
    int integer(String key) {
      final v = j[key];
      if (v is int) return v;
      throw FormatException('Invalid $key');
    }

    final points = integer('points_required'),
        available = integer('available_quantity');
    if (points < 0 || available < 0) {
      throw const FormatException('Invalid reward values');
    }
    return RewardItem(
      id: integer('id'),
      name: j['name'] is String
          ? j['name']! as String
          : (throw const FormatException('Invalid name')),
      description: j['description'] is String
          ? j['description']! as String
          : '',
      category: j['category'] is String ? j['category']! as String : '',
      pointsRequired: points,
      imageUrl:
          j['image_url'] is String && (j['image_url']! as String).isNotEmpty
          ? j['image_url']! as String
          : null,
      availability: RewardAvailabilityX.parse(j['availability']),
      stock: RewardStock(availableQuantity: available),
      minimumQuantity: integer('minimum_quantity'),
      maximumQuantity: integer('maximum_quantity'),
      requiresRewardEvent: j['requires_reward_event'] == true,
      updatedAt: j['updated_at'] is String
          ? DateTime.tryParse(j['updated_at']! as String)?.toUtc()
          : null,
    );
  }
  final int id, pointsRequired, minimumQuantity, maximumQuantity;
  final String name, description, category;
  final String? imageUrl;
  final RewardAvailability availability;
  final RewardStock stock;
  final bool requiresRewardEvent;
  final DateTime? updatedAt;
}
