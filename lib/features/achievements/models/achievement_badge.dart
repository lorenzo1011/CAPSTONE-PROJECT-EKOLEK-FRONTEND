import 'badge_requirement_type.dart';
import 'badge_status.dart';

class AchievementBadge {
  const AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.badgeType,
    required this.badgeTypeLabel,
    required this.requirementType,
    required this.requirementLabel,
    required this.status,
    required this.isUnlocked,
    this.iconUrl,
    this.progressValue,
    this.progressTarget,
    this.progressPercentage,
    this.progressUnit,
    this.unlockedAt,
  });

  factory AchievementBadge.fromJson(Map<String, Object?> json) {
    final id = json['id'], name = json['name'];
    if (id is! int || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid resident badge response.');
    }
    final status = BadgeStatus.fromJson(json['status']);
    return AchievementBadge(
      id: id,
      name: name,
      description: json['description'] as String? ?? '',
      iconUrl: _text(json['icon_url']),
      badgeType: json['badge_type'] as String? ?? 'UNKNOWN',
      badgeTypeLabel: json['badge_type_label'] as String? ?? 'Achievement',
      requirementType: BadgeRequirementType.fromJson(json['condition_type']),
      requirementLabel:
          json['condition_label'] as String? ?? 'Requirement unavailable',
      progressValue: _number(json['progress_value']),
      progressTarget: _number(json['progress_target']),
      progressPercentage: _number(json['progress_percentage']),
      progressUnit: _text(json['progress_unit']),
      status: status,
      isUnlocked: json['is_unlocked'] == true && status.isUnlocked,
      unlockedAt: DateTime.tryParse(json['unlocked_at'] as String? ?? ''),
    );
  }

  final int id;
  final String name;
  final String description;
  final String? iconUrl;
  final String badgeType;
  final String badgeTypeLabel;
  final BadgeRequirementType requirementType;
  final String requirementLabel;
  final num? progressValue;
  final num? progressTarget;
  final num? progressPercentage;
  final String? progressUnit;
  final BadgeStatus status;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  double? get displayProgress => progressPercentage == null
      ? null
      : progressPercentage!.toDouble().clamp(0, 100) / 100;
  static num? _number(Object? value) => value is num
      ? value
      : value is String
      ? num.tryParse(value)
      : null;
  static String? _text(Object? value) =>
      value is String && value.isNotEmpty ? value : null;
  @override
  String toString() => 'AchievementBadge(id: $id, status: ${status.name})';
}
