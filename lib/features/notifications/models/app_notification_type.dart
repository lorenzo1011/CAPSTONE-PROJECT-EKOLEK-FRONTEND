import 'package:flutter/material.dart';

enum AppNotificationType {
  accountApproved('ACCOUNT_APPROVED', 'Account', Icons.verified_user_outlined),
  accountRejected('ACCOUNT_REJECTED', 'Account', Icons.person_off_outlined),
  collectionEvent(
    'COLLECTION_EVENT',
    'Collection schedule',
    Icons.recycling_rounded,
  ),
  rewardEvent('REWARD_EVENT', 'Reward schedule', Icons.card_giftcard_outlined),
  pointsEarned('POINTS_EARNED', 'Points', Icons.eco_outlined),
  rewardRedeemed('REWARD_REDEEMED', 'Reward', Icons.redeem_outlined),
  newVideo('NEW_VIDEO', 'Learning', Icons.play_circle_outline_rounded),
  newGame('NEW_GAME', 'Game', Icons.sports_esports_outlined),
  newChallenge('NEW_CHALLENGE', 'Challenge', Icons.flag_outlined),
  announcement('ANNOUNCEMENT', 'Announcement', Icons.campaign_outlined),
  system('SYSTEM', 'System', Icons.info_outline_rounded),
  unknown('UNKNOWN', 'Update', Icons.notifications_none_rounded);

  const AppNotificationType(this.value, this.label, this.icon);
  final String value, label;
  final IconData icon;
  static AppNotificationType fromJson(Object? value) =>
      AppNotificationType.values.firstWhere(
        (item) => item.value == value,
        orElse: () => AppNotificationType.unknown,
      );
}
