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
  final model.User user;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;
  final VoidCallback onLogoutTap;

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
          radius: 64,
          backgroundImage: NetworkImage(user.profilePictureUrl),
        ),
        const SizedBox(height: 20),
        // Active Switch
        ActiveSwitchRow(
          isActive: user.isActive,
          onChanged: onActiveChanged,
        ),
        const SizedBox(height: 20),
        // Username
        CustomText(
          text: user.username,
          fontSize: CustomFont.fontSize24,
          fontWeight: CustomFont.fontWeightBold,
          color: CustomColor.white,
        ),
        const SizedBox(height: 10),
        // Bio
        CustomText(
          text: user.bio,
          fontSize: CustomFont.fontSize16,
          color: CustomColor.white70,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Followers and Following
        FollowersFollowingRow(
          followersCount: user.followers.length,
          followingCount: user.following.length,
          onFollowersTap: onFollowersTap,
          onFollowingTap: onFollowingTap,
        ),
        const SizedBox(height: 40),
        // Log out button
        CustomGradientButton(
          text: CustomString.logOut,
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}
