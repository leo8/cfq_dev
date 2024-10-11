import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';

class CfqUserInfoHeader extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final DateTime datePublished;
  final VoidCallback onFollowPressed;

  const CfqUserInfoHeader({
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.datePublished,
    required this.onFollowPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomAvatar(
          imageUrl: profilePictureUrl,
          radius: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: username,
                    color: CustomColor.white,
                    fontWeight: CustomFont.fontWeightBold,
                    fontSize: CustomFont.fontSize16,
                  ),
                  const SizedBox(width: 4),
                  CustomText(
                    text: DateTimeUtils.getTimeAgo(datePublished),
                    color: CustomColor.white54,
                    fontSize: CustomFont.fontSize12,
                  ),
                ],
              ),
              const CustomText(
                text: CustomString.cfqCapital +
                    CustomString.space +
                    CustomString.interrogationMark,
                color: CustomColor.white,
                fontSize: CustomFont.fontSize18,
                fontWeight: CustomFont.fontWeightBold,
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: CustomColor.white),
              onPressed: onFollowPressed,
            ),
            IconButton(
              icon: const Icon(CustomIcon.eventConversation,
                  color: CustomColor.white),
              onPressed: () {/* Implement messaging functionality */},
            ),
          ],
        ),
      ],
    );
  }
}
