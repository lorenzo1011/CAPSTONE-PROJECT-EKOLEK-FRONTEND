import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/app_notification.dart';

class AppNotificationTile extends StatelessWidget {
  const AppNotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${notification.title}, ${notification.type.label}, '
          '${notification.isUnread ? 'unread' : 'read'}, '
          '${AppFormatters.dateTime(notification.createdAt)}',
      child: Card(
        color: notification.isUnread
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          leading: Badge(
            isLabelVisible: notification.isUnread,
            child: Icon(notification.type.icon),
          ),
          title: Text(
            notification.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: notification.isUnread
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(AppFormatters.dateTime(notification.createdAt)),
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
