import 'package:ekolek_app/core/api/api_endpoints.dart';
import 'package:ekolek_app/features/learning/models/learning_video.dart';
import 'package:ekolek_app/features/learning/models/video_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Learning contract', () {
    test('uses only verified resident endpoints', () {
      expect(ApiEndpoints.learningVideos, 'mobile/learning/videos/');
      expect(ApiEndpoints.learningVideo(7), 'mobile/learning/videos/7/');
      expect(
        ApiEndpoints.learningVideoProgress(7),
        'mobile/learning/videos/7/progress/',
      );
      expect(
        ApiEndpoints.learningVideoComplete(7),
        'mobile/learning/videos/7/complete/',
      );
      expect(ApiEndpoints.learningVideos, isNot(contains('admin')));
    });

    test('parses verified YouTube detail and backend state', () {
      final video = LearningVideo.fromJson({
        'id': 1,
        'title': 'Waste segregation',
        'description': 'Learn the verified process.',
        'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        'category': 'Recycling',
        'points_reward': 20,
        'required_watch_percentage': 90,
        'video_source': 'youtube',
        'provider_video_id': 'dQw4w9WgXcQ',
        'progress': {
          'watch_percentage': 35,
          'is_completed': false,
          'points_awarded': false,
        },
        'quiz': {
          'id': 9,
          'title': 'Quick check',
          'description': '',
          'passing_score': 75,
          'points_reward': 5,
          'max_attempts': 3,
          'question_count': 4,
          'attempt_count': 0,
          'is_passed': false,
          'is_unlocked': false,
        },
      });
      expect(video.source, LearningVideoSource.youtube);
      expect(video.progress?.canResume, isTrue);
      expect(video.quiz?.isUnlocked, isFalse);
    });

    test('unknown source fails safely', () {
      final video = LearningVideo.fromJson({
        'id': 2,
        'title': 'Unknown',
        'category': '',
        'points_reward': 0,
        'required_watch_percentage': 90,
        'video_source': 'future-provider',
      });
      expect(video.source, LearningVideoSource.unsupported);
      expect(video.providerVideoId, isNull);
    });

    test('malformed progress does not unlock completion', () {
      final progress = VideoProgress.fromJson({
        'watch_percentage': '100',
        'is_completed': 'true',
        'points_awarded': 'true',
      });
      expect(progress.watchPercentage, 0);
      expect(progress.isCompleted, isFalse);
      expect(progress.pointsAwarded, isFalse);
    });

    test('progress display is clamped without granting completion', () {
      final progress = VideoProgress.fromJson({
        'watch_percentage': 250,
        'is_completed': false,
        'points_awarded': false,
      });
      expect(progress.watchPercentage, 100);
      expect(progress.isCompleted, isFalse);
    });
  });
}
