import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:cfq_dev/widgets/atoms/buttons/custom_elevated_button.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';

class CfqUserInfoHeader extends StatelessWidget {
  final String profilePictureUrl; // User's profile picture URL
  final String username; // User's username
  final List<String> organizers; // List of organizers
  final DateTime datePublished; // Event publication date
  final VoidCallback onFollowPressed; // Callback for follow button

  const CfqUserInfoHeader({
    required this.profilePictureUrl, // User profile picture URL
    required this.username, // Username of the event creator
    required this.organizers, // Organizers of the CFQ event
    required this.datePublished, // Publication date of the CFQ event
    required this.onFollowPressed, // Action triggered when the follow button is pressed
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Picture Avatar
        CustomAvatar(
          imageUrl: profilePictureUrl, // User's profile picture
          radius: 28, // Circle avatar size
        ),
        const SizedBox(width: 12), // Space between avatar and username
        // Username and Additional Information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Username Text
                  CustomText(
                    text: username,
                    color: CustomColor.white,
                    fontWeight: CustomFont.fontWeightBold,
                    fontSize: CustomFont.fontSize16,
                  ),
                  const SizedBox(width: 4),
                  // Organizers Information
                  CustomText(
                    text: 'à ${organizers.join(', ')}', // Organizers names
                    color: CustomColor.blueAccent,
                    fontWeight: CustomFont.fontWeight600,
                    fontSize: CustomFont.fontSize14,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Date of Publication
              CustomText(
                text:
                    '${datePublished.day}/${datePublished.month}/${datePublished.year}', // Date formatted as dd/mm/yyyy
                color: CustomColor.white54,
                fontSize: CustomFont.fontSize12,
              ),
            ],
          ),
        ),
        // Follow Button
        CustomElevatedButton(
          onPressed: onFollowPressed, // Follow button callback
          backgroundColor: CustomColor.personnalizedPurple, // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Button border radius
          ),
          child: const CustomText(
            text: CustomString.follow, // Button label
            color: CustomColor.white,
            fontSize: CustomFont.fontSize14,
          ),
        ),
      ],
    );
  }
}
