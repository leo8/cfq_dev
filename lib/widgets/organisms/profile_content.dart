import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/custom_circle_avatar.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:cfq_dev/widgets/molecules/followers_following_row.dart';
import 'package:cfq_dev/models/user.dart' as model;

import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';
import '../atoms/buttons/custom_gradient_button.dart';
import '../molecules/active_switch_row.dart';

class ProfileContent extends StatelessWidget {
  final model.User user; // User model containing profile information
  final ValueChanged<bool>
      onActiveChanged; // Callback for toggling active status
  final VoidCallback onFollowersTap; // Callback for followers count tap
  final VoidCallback onFollowingTap; // Callback for following count tap
  final VoidCallback onLogoutTap; // Callback for logout action

  const ProfileContent({
    required this.user,
    required this.onActiveChanged,
    required this.onFollowersTap,
    required this.onFollowingTap,
    required this.onLogoutTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Profile Picture
        CustomCircleAvatar(
          radius: 64, // Size of the avatar
          backgroundImage:
              NetworkImage(user.profilePictureUrl), // User's profile picture
        ),
        const SizedBox(height: 20),
        // Active Switch
        ActiveSwitchRow(
          isActive: user.isActive, // Current active status of the user
          onChanged:
              onActiveChanged, // Callback when the active status is changed
        ),
        const SizedBox(height: 20),
        // Username
        CustomText(
          text: user.username, // Display user's name
          fontSize: CustomFont.fontSize24,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.white,
        ),
        const SizedBox(height: 10),
        // Bio
        CustomText(
          text: user.bio, // Display user's bio
          fontSize: CustomFont.fontSize16,
          color: CustomColor.white70,
          textAlign: TextAlign.center, // Center align bio text
        ),
        const SizedBox(height: 20),
        // Followers and Following
        FollowersFollowingRow(
          followersCount: user.followers.length, // Count of followers
          followingCount: user.following.length, // Count of following
          onFollowersTap: onFollowersTap, // Callback for followers tap
          onFollowingTap: onFollowingTap, // Callback for following tap
        ),
        const SizedBox(height: 40),
        // Log out button
        CustomGradientButton(
          text: CustomString.logOut, // Log out button text
          onTap: onLogoutTap, // Callback for logout action
        ),
      ],
    );
  }
}
