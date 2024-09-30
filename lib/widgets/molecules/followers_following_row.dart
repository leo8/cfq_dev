import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';

class FollowersFollowingRow extends StatelessWidget {
  final int followersCount;
  final int followingCount;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Followers
        GestureDetector(
          onTap: onFollowersTap,
          child: Column(
            children: [
              CustomText(
                text: '$followersCount',
                fontSize: CustomFont.fontSize18,
                fontWeight: CustomFont.fontWeightBold,
                color: CustomColor.white,
              ),
              const CustomText(
                text: CustomString.followers,
                fontSize: CustomFont.fontSize14,
                color: CustomColor.white70,
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Following
        GestureDetector(
          onTap: onFollowingTap,
          child: Column(
            children: [
              CustomText(
                text: '$followingCount',
                fontSize: CustomFont.fontSize18,
                fontWeight: CustomFont.fontWeightBold,
                color: CustomColor.white,
              ),
              const CustomText(
                text: CustomString.following,
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
