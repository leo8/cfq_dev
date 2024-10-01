import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';

class FollowersFollowingRow extends StatelessWidget {
  final int followersCount; // Number of followers
  final int followingCount; // Number of users the person is following
  final VoidCallback onFollowersTap; // Callback when followers are tapped
  final VoidCallback onFollowingTap; // Callback when following is tapped

  const FollowersFollowingRow({
    required this.followersCount,
    required this.followingCount,
    required this.onFollowersTap,
    required this.onFollowingTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Center the items horizontally
      children: [
        // Followers Section
        GestureDetector(
          onTap: onFollowersTap, // Trigger the followers tap callback
          child: Column(
            children: [
              CustomText(
                text: '$followersCount', // Display the followers count
                fontSize: CustomFont.fontSize18,
                fontWeight: CustomFont.fontWeightBold,
                color: CustomColor.white,
              ),
              const CustomText(
                text: CustomString.followers, // Label for followers
                fontSize: CustomFont.fontSize14,
                color: CustomColor.white70,
              ),
            ],
          ),
        ),
        const SizedBox(width: 40), // Spacing between followers and following
        // Following Section
        GestureDetector(
          onTap: onFollowingTap, // Trigger the following tap callback
          child: Column(
            children: [
              CustomText(
                text: '$followingCount', // Display the following count
                fontSize: CustomFont.fontSize18,
                fontWeight: CustomFont.fontWeightBold,
                color: CustomColor.white,
              ),
              const CustomText(
                text: CustomString.following, // Label for following
                fontSize: CustomFont.fontSize14,
                color: CustomColor.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
