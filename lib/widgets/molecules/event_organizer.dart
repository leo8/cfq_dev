import 'package:flutter/material.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';
import '../atoms/texts/custom_text.dart';
import '../atoms/avatars/custom_avatar.dart';

class EventOrganizer extends StatelessWidget {
  final String profilePictureUrl;
  final String username;

  const EventOrganizer(
      {super.key, required this.profilePictureUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 25),
        CustomIcon.eventOrganizer.copyWith(size: 28),
        const SizedBox(width: 10),
        CustomText(
          text: CustomString.organizedBy,
          textStyle: CustomTextStyle.body2,
        ),
        const SizedBox(width: 25),
        CustomAvatar(
          imageUrl: profilePictureUrl,
          radius: 20,
        ),
        const SizedBox(width: 10),
        CustomText(
          text: username,
          textStyle: CustomTextStyle.body2,
        ),
      ],
    );
  }
}
