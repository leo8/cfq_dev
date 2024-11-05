import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../../utils/styles/text_styles.dart';
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
    if (notification.type == model.NotificationType.eventInvitation) {
      final content =
          notification.content as model.EventInvitationNotificationContent;

      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CustomAvatar(
                imageUrl: content.organizerProfilePictureUrl,
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
                        children: [
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
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
