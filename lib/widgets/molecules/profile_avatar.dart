import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String username;

  const ProfileAvatar({
    required this.imageUrl,
    required this.username,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAvatar(imageUrl: imageUrl),
        const SizedBox(height: 5),
        CustomText(
          text: username,
          fontSize: CustomFont.fontSize12,
          color: CustomColor.white70,
        ),
      ],
    );
  }
}
