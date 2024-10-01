import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl; // URL of the profile image
  final String username; // The username to display below the avatar

  const ProfileAvatar({
    required this.imageUrl,
    required this.username,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the avatar with the profile image
        CustomAvatar(imageUrl: imageUrl),
        const SizedBox(height: 5), // Spacing between avatar and username
        // Display the username below the avatar
        CustomText(
          text: username,
          fontSize: CustomFont.fontSize12,
          color: CustomColor.white70, // Subtle text color
        ),
      ],
    );
  }
}
