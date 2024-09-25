import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/atoms/buttons/custom_elevated_button.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/string.dart';

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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Picture
        CustomAvatar(
          imageUrl: profilePictureUrl,
          radius: 28,
        ),
        const SizedBox(width: 12),
        // Username and Additional Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: username,
                    color: CustomColor.primaryColor,
                    fontWeight: CustomFont.fontWeightBold,
                    fontSize: CustomFont.fontSize16,
                  ),
                  const SizedBox(width: 4),
                  // Display organizers list joined by commas
                  CustomText(
                    text: 'à ${organizers.join(', ')}',
                    color: CustomColor.blueAccent,
                    fontWeight: CustomFont.fontWeight600,
                    fontSize: CustomFont.fontSize14,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              CustomText(
                text:
                    '${datePublished.day}/${datePublished.month}/${datePublished.year}',
                color: CustomColor.white54,
                fontSize: CustomFont.fontSize12,
              ),
            ],
          ),
        ),
        // Follow Button
        CustomElevatedButton(
          onPressed: onFollowPressed,
          backgroundColor: CustomColor.personnalizedPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CustomText(
            text: CustomString.follow,
            color: CustomColor.primaryColor,
            fontSize: CustomFont.fontSize14,
          ),
        ),
      ],
    );
  }
}
