import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class FriendsCount extends StatelessWidget {
  final int friendsCount; // Number of friends
  final VoidCallback onFriendsTap; // Callback when friends are tapped

  const FriendsCount({
    required this.friendsCount,
    required this.onFriendsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFriendsTap, // Trigger the friends tap callback
      child: Column(
        children: [
          CustomText(
            text: '$friendsCount', // Display the friends count
            fontSize: CustomFont.fontSize18,
            fontWeight: CustomFont.fontWeightBold,
            color: CustomColor.white,
          ),
          const CustomText(
            text: 'Friends', // Label for friends
            fontSize: CustomFont.fontSize14,
            color: CustomColor.white70,
          ),
        ],
      ),
    );
  }
}
