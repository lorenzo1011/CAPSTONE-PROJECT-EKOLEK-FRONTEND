import 'package:flutter/material.dart';

enum ChallengeType {
  collectMaterial,
  earnPoints,
  completeVideos,
  passQuizzes,
  playGames,
  unknown;

  factory ChallengeType.fromBackend(Object? value) => switch (value) {
    'COLLECT_MATERIAL' => collectMaterial,
    'EARN_POINTS' => earnPoints,
    'COMPLETE_VIDEOS' => completeVideos,
    'PASS_QUIZZES' => passQuizzes,
    'PLAY_GAMES' => playGames,
    _ => unknown,
  };

  IconData get icon => switch (this) {
    collectMaterial => Icons.recycling_rounded,
    earnPoints => Icons.stars_rounded,
    completeVideos => Icons.play_circle_rounded,
    passQuizzes => Icons.quiz_rounded,
    playGames => Icons.sports_esports_rounded,
    unknown => Icons.eco_rounded,
  };

  String get label => switch (this) {
    collectMaterial => 'Material collection',
    earnPoints => 'Point activity',
    completeVideos => 'Learning videos',
    passQuizzes => 'Quizzes',
    playGames => 'Games',
    unknown => 'Eco challenge',
  };
}
