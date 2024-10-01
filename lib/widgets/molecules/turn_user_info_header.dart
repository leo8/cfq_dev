import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:cfq_dev/widgets/atoms/buttons/custom_elevated_button.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';

class TurnUserInfoHeader extends StatelessWidget {
  final String profilePictureUrl; // URL of the user's profile picture
  final String username; // Username of the user
  final List<String> organizers; // List of event organizers
  final String timeInfo; // Information about the event time
  final VoidCallback onAttendingPressed; // Callback for attending button

  const TurnUserInfoHeader({
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.timeInfo,
    required this.onAttendingPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Picture
        CustomAvatar(
          imageUrl: profilePictureUrl, // Display user's profile picture
          radius: 28, // Avatar size
        ),
        const SizedBox(width: 12), // Spacing between avatar and text
        // Username and Additional Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: username, // Username
                    color: CustomColor.white,
                    fontWeight: CustomFont.fontWeightBold,
                    fontSize: CustomFont.fontSize16,
                  ),
                  const SizedBox(width: 4), // Spacing after username
                  // Display organizers list if available
                  if (organizers.isNotEmpty)
                    CustomText(
                      text: 'à ${organizers.join(', ')}', // Organizers
                      color: CustomColor.blueAccent,
                      fontWeight: CustomFont.fontWeight600,
                      fontSize: CustomFont.fontSize14,
                    ),
                ],
              ),
              const SizedBox(height: 4), // Spacing after the row
              CustomText(
                text: timeInfo, // Event time info (e.g., 'une heure')
                color: CustomColor.white54,
                fontSize: CustomFont.fontSize12,
              ),
            ],
          ),
        ),
        // Attendee Button
        CustomElevatedButton(
          onPressed: onAttendingPressed, // Callback for button
          backgroundColor: CustomColor.personnalizedPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CustomText(
            text: CustomString.jeSuisLa, // Button text
            color: CustomColor.white,
            fontSize: CustomFont.fontSize14,
          ),
        ),
      ],
    );
  }
}
