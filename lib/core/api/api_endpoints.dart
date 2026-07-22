class ApiEndpoints {
  ApiEndpoints._();

  /// Confirmed high-level Django URL prefixes for the Resident App.
  static const String auth = 'auth/';
  static const String mobile = 'mobile/';

  static const String login = '${auth}login/';
  static const String refresh = '${auth}token/refresh/';
  static const String currentUser = '${auth}me/';
  static const String profile = '${mobile}profile/';
  static const String passwordResetRequest = '${auth}password-reset/request/';
  static const String passwordResetVerify = '${auth}password-reset/verify/';
  static const String passwordResetConfirm = '${auth}password-reset/confirm/';
  static const String changePassword = '${auth}change-password/';
  static const String wallet = '${mobile}wallet/';
  static const String digitalResidentId = '${mobile}digital-id/';
  static const String pointTransactions = '${mobile}point-transactions/';
  static const String recycling = '${mobile}recycling/';
  static String recyclingDetail(int id) => '$recycling$id/';
  static const String materials = '${mobile}materials/';
  static const String collectionEvents = '${mobile}collection-events/';
  static const String rewardEvents = '${mobile}reward-events/';
  static String collectionEvent(int id) => '$collectionEvents$id/';
  static String rewardEvent(int id) => '$rewardEvents$id/';
  static const String learningVideos = '${mobile}learning/videos/';
  static String learningVideo(int id) => '$learningVideos$id/';
  static String learningVideoProgress(int id) =>
      '${learningVideo(id)}progress/';
  static String learningVideoComplete(int id) =>
      '${learningVideo(id)}complete/';
  static String learningQuiz(int id) => '${mobile}quizzes/$id/';
  static String submitLearningQuiz(int id) => '${learningQuiz(id)}submit/';
  static const String games = '${mobile}games/';
  static String game(int id) => '$games$id/';
  static const String dailyGameProgress = '${games}daily-progress/';
  static const String gameAttempts = '${games}attempts/';
  static const String challenges = '${mobile}challenges/';
  static String challenge(int id) => '$challenges$id/';
  static const String challengeProgress = '${challenges}progress/';
  static const String badges = '${mobile}badges/';
  static const String unlockedBadges = '${badges}unlocked/';
  static const String badgeSummary = '${badges}summary/';
  static String badge(int id) => '$badges$id/';
  static const String leaderboard = '${mobile}leaderboard/';
  static const String barangayLeaderboard = '${leaderboard}barangays/';
  static const String currentResidentRank = '${leaderboard}me/';
  static const String currentBarangayRank = '${leaderboard}barangay/me/';
  static const String notifications = '${mobile}notifications/';
  static String notification(int id) => '$notifications$id/';
  static String markNotificationRead(int id) => '${notification(id)}read/';
  static const String notificationUnreadCount = '${notifications}unread-count/';
  static const String markAllNotificationsRead =
      '${notifications}mark-all-read/';
  static const String deviceToken = '${mobile}device-token/';
  static const String rewards = '${mobile}rewards/';
  static const String rewardCategories = '${rewards}categories/';
  static String reward(int id) => '$rewards$id/';
  static String rewardEligibility(int id) => '${reward(id)}eligibility/';
  static String rewardPreview(int id) => '${reward(id)}preview/';
  static String rewardValidEvents(int id) => '${reward(id)}events/';
  static const String redemptionRequests = '${mobile}reservations/';
  static const String redemptionRequestLookup = '${redemptionRequests}lookup/';
  static String redemptionRequest(int id) => '$redemptionRequests$id/';
  static String cancelRedemptionRequest(int id) =>
      '${redemptionRequest(id)}cancel/';

  // Exact endpoint paths belong here after the Django URL configuration or
  // finalized OpenAPI schema is reviewed for the relevant feature phase.
}
