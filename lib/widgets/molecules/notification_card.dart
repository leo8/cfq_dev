import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/colors.dart';
import '../atoms/avatars/custom_avatar.dart';

class NotificationCard extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _buildNotificationContent(),
      ),
    );
  }

  Widget _buildNotificationContent() {
    switch (notification.type) {
      case model.NotificationType.eventInvitation:
        final content =
            notification.content as model.EventInvitationNotificationContent;
        return _buildNotificationRow(
          avatarUrl: content.organizerProfilePictureUrl,
          content: [
            TextSpan(
              text: content.organizerUsername,
              style: CustomTextStyle.body1Bold,
            ),
            const TextSpan(text: ' t\'invite à '),
            TextSpan(
              text: content.eventName,
              style: CustomTextStyle.body1Bold,
            ),
          ],
          timestamp: notification.timestamp,
        );

      case model.NotificationType.teamRequest:
        final content =
            notification.content as model.TeamRequestNotificationContent;
        return _buildNotificationRow(
          avatarUrl: content.inviterProfilePictureUrl,
          content: [
            TextSpan(
              text: content.inviterUsername,
              style: CustomTextStyle.body1Bold,
            ),
            const TextSpan(text: ' t\'invite à rejoindre '),
            TextSpan(
              text: content.teamName,
              style: CustomTextStyle.body1Bold,
            ),
          ],
          timestamp: notification.timestamp,
        );

      case model.NotificationType.followUp:
        final content =
            notification.content as model.FollowUpNotificationContent;
        return _buildNotificationRow(
          avatarUrl: content.followerProfilePictureUrl,
          content: [
            TextSpan(
              text: content.followerUsername,
              style: CustomTextStyle.body1Bold,
            ),
            const TextSpan(text: ' suit '),
            TextSpan(
              text: content.cfqName,
              style: CustomTextStyle.body1Bold,
            ),
          ],
          timestamp: notification.timestamp,
        );

      case model.NotificationType.attending:
        final content =
            notification.content as model.AttendingNotificationContent;
        return _buildNotificationRow(
          avatarUrl: content.attendingProfilePictureUrl,
          content: [
            TextSpan(
              text: content.attendingUsername,
              style: CustomTextStyle.body1Bold,
            ),
            const TextSpan(text: ' participera à '),
            TextSpan(
              text: content.turnName,
              style: CustomTextStyle.body1Bold,
            ),
          ],
          timestamp: notification.timestamp,
        );

      case model.NotificationType.friendRequest:
        final content =
            notification.content as model.FriendRequestNotificationContent;
        return _buildNotificationRow(
          avatarUrl: content.requesterProfilePictureUrl,
          content: [
            TextSpan(
              text: content.requesterUsername,
              style: CustomTextStyle.body1Bold,
            ),
            const TextSpan(text: ' souhaite t\'ajouter en ami'),
          ],
          timestamp: notification.timestamp,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNotificationRow({
    required String avatarUrl,
    required List<TextSpan> content,
    required DateTime timestamp,
  }) {
    return Row(
      children: [
        CustomAvatar(
          imageUrl: avatarUrl,
          radius: 25,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: CustomTextStyle.body1,
                  children: content,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getTimeAgo(timestamp),
                style: CustomTextStyle.body2.copyWith(
                  color: CustomColor.grey300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }
}
