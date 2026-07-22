import 'challenge_progress.dart';
import 'challenge_status.dart';
import 'challenge_type.dart';

class EcoChallenge {
  const EcoChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.goalUnit,
    required this.bonusPoints,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isCityWide,
    required this.isEligible,
    this.progress,
  });

  factory EcoChallenge.fromJson(Map<String, Object?> json) {
    final rawProgress = json['progress'];
    return EcoChallenge(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Eco challenge',
      description: json['description'] as String? ?? '',
      type: ChallengeType.fromBackend(json['challenge_type']),
      targetValue: json['target_value'] as int? ?? 0,
      goalUnit: json['goal_unit'] as String? ?? 'units',
      bonusPoints: json['bonus_points'] as int? ?? 0,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? ''),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? ''),
      status: ChallengeStatus.fromBackend(json['status']),
      isCityWide: json['is_city_wide'] == true,
      isEligible: json['is_eligible'] == true,
      progress: rawProgress is Map
          ? ChallengeProgress.fromJson(
              rawProgress.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
    );
  }

  final int id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  final String goalUnit;
  final int bonusPoints;
  final DateTime? startDate;
  final DateTime? endDate;
  final ChallengeStatus status;
  final bool isCityWide;
  final bool isEligible;
  final ChallengeProgress? progress;

  bool get isCompleted => progress?.isCompleted ?? false;
}
