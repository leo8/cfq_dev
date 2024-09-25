import 'package:flutter/material.dart';
import '../atoms/custom_avatar.dart';
import '../atoms/custom_text.dart';
import '../utils/fonts.dart';
import '../utils/colors.dart';

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
