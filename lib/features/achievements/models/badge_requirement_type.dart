import 'package:flutter/material.dart';

enum BadgeRequirementType {
  firstCollection('First collection', Icons.recycling_rounded),
  recyclingWeight('Recycled weight', Icons.scale_rounded),
  recyclingPoints('Recycling points', Icons.eco_rounded),
  learningVideos('Learning videos', Icons.play_circle_outline_rounded),
  quizzesPassed('Passed quizzes', Icons.quiz_outlined),
  gamesPlayed('Games played', Icons.sports_esports_outlined),
  challengesCompleted('Completed challenges', Icons.flag_outlined),
  manual('Verified manually', Icons.fact_check_outlined),
  unknown('Requirement unavailable', Icons.military_tech_outlined);

  const BadgeRequirementType(this.label, this.icon);
  final String label;
  final IconData icon;

  static BadgeRequirementType fromJson(Object? value) => switch (value) {
    'FIRST_COLLECTION' => firstCollection,
    'TOTAL_KG_RECYCLED' => recyclingWeight,
    'TOTAL_POINTS_EARNED' => recyclingPoints,
    'VIDEOS_COMPLETED' => learningVideos,
    'QUIZZES_PASSED' => quizzesPassed,
    'GAMES_PLAYED' => gamesPlayed,
    'CHALLENGES_COMPLETED' => challengesCompleted,
    'MANUAL_AWARD' => manual,
    _ => unknown,
  };
}
