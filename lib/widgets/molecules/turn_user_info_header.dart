import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/custom_avatar.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:cfq_dev/widgets/atoms/buttons/custom_elevated_button.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';

class TurnUserInfoHeader extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final String timeInfo;
  final VoidCallback onAttendingPressed;

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
                    color: CustomColor.white,
                    fontWeight: CustomFont.fontWeightBold,
                    fontSize: CustomFont.fontSize16,
                  ),
                  const SizedBox(width: 4),
                  // Display organizers list joined by commas
                  if (organizers.isNotEmpty)
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
                text: timeInfo, // This can be 'une heure' or calculated time
                color: CustomColor.white54,
                fontSize: CustomFont.fontSize12,
              ),
            ],
          ),
        ),
        // Attendee Button
        CustomElevatedButton(
          onPressed: onAttendingPressed,
          backgroundColor: CustomColor.personnalizedPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CustomText(
            text: CustomString.jeSuisLa,
            color: CustomColor.white,
            fontSize: CustomFont.fontSize14,
          ),
        ),
      ],
    );
  }
}
