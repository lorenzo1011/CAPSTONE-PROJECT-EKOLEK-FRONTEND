enum NotificationActionType {
  collectionEvent,
  rewardEvent,
  reward,
  redemption,
  learningVideo,
  game,
  challenge,
  achievement,
  leaderboard,
  wallet,
  detail,
}

class NotificationAction {
  const NotificationAction(this.type, this.entityId);
  final NotificationActionType type;
  final int? entityId;
  factory NotificationAction.fromJson(Object? type, Object? id) {
    final entityId = id is int
        ? id
        : id is String
        ? int.tryParse(id)
        : null;
    return NotificationAction(switch (type) {
      'COLLECTION_EVENT' => NotificationActionType.collectionEvent,
      'REWARD_EVENT' => NotificationActionType.rewardEvent,
      'REWARD' => NotificationActionType.reward,
      'REDEMPTION' => NotificationActionType.redemption,
      'LEARNING_VIDEO' => NotificationActionType.learningVideo,
      'GAME' => NotificationActionType.game,
      'CHALLENGE' => NotificationActionType.challenge,
      'ACHIEVEMENT' => NotificationActionType.achievement,
      'LEADERBOARD' => NotificationActionType.leaderboard,
      'WALLET' => NotificationActionType.wallet,
      _ => NotificationActionType.detail,
    }, entityId);
  }
  bool get hasValidEntity =>
      type == NotificationActionType.leaderboard ||
      type == NotificationActionType.wallet ||
      (type != NotificationActionType.detail &&
          entityId != null &&
          entityId! > 0);
}
