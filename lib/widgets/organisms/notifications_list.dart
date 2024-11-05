import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../molecules/notification_card.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/colors.dart';

class NotificationsList extends StatelessWidget {
  final List<model.Notification> notifications;
  final bool isLoading;
  final Stream<int> unreadCountStream;

  const NotificationsList({
    super.key,
    required this.notifications,
    required this.isLoading,
    required this.unreadCountStream,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'Pas encore de notifications',
          style: CustomTextStyle.body1,
        ),
      );
    }

    return StreamBuilder<int>(
      stream: unreadCountStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur de chargement des notifications',
              style: CustomTextStyle.body1,
            ),
          );
        }

        final unreadCount = snapshot.data ?? 0;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final bool isUnread = index < unreadCount;

            return Column(
              children: [
                Container(
                  color: isUnread
                      ? CustomColor.customDarkGrey
                      : Colors.transparent,
                  child: NotificationCard(
                    notification: notification,
                    onTap: () {
                      // Handle navigation based on notification type
                      switch (notification.type) {
                        case model.NotificationType.followUp:
                          final content = notification.content
                              as model.FollowUpNotificationContent;
                          // Navigate to CFQ details
                          // TODO: Implement navigation to CFQ
                          break;
                        case model.NotificationType.eventInvitation:
                          final content = notification.content
                              as model.EventInvitationNotificationContent;
                          // Navigate to event details
                          // TODO: Implement navigation to event
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                ),
                if (index < notifications.length - 1)
                  const Divider(height: 1, color: CustomColor.customDarkGrey),
              ],
            );
          },
        );
      },
    );
  }
}
