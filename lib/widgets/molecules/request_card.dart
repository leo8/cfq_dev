import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';
import '../atoms/avatars/custom_avatar.dart';
import '../atoms/buttons/custom_button.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  const RequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomAvatar(
                imageUrl: request.requesterProfilePictureUrl,
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
                            text: request.requesterUsername,
                            style: CustomTextStyle.body1Bold,
                          ),
                          TextSpan(
                            text: request.type == RequestType.team
                                ? ' t\'invite à rejoindre '
                                : ' souhaite t\'ajouter en ami',
                          ),
                          if (request.type == RequestType.team)
                            TextSpan(
                              text: request.teamName,
                              style: CustomTextStyle.body1Bold,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTimeAgo(request.timestamp),
                      style: CustomTextStyle.body2.copyWith(
                        color: CustomColor.grey300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: CustomString.addFriend,
                  onTap: onAccept,
                  color: CustomColor.customPurple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  label: CustomString.removeFriend,
                  onTap: onDeny,
                  color: CustomColor.customDarkGrey,
                ),
              ),
            ],
          ),
        ],
      ),
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
