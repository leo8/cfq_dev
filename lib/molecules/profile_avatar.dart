import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String username;

  const ProfileAvatar({
    required this.imageUrl,
    required this.username,
    Key? key,
  }) : super(key: key);

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
