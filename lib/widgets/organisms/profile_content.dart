import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;

class ProfileContent extends StatelessWidget {
  final model.User user;
  final Function(bool)? onActiveChanged;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onAddFriendTap;

  const ProfileContent({
    required this.user,
    this.onActiveChanged,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onLogoutTap,
    this.onAddFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    // Build the profile UI components
    return Column(
      children: [
        // Profile picture, username, bio, etc.
        // ...

        // Display active status switch if onActiveChanged is provided
        if (onActiveChanged != null)
          Switch(
            value: user.isActive,
            onChanged: onActiveChanged,
          ),

        // Display 'Ajouter' button if onAddFriendTap is provided
        if (onAddFriendTap != null)
          ElevatedButton(
            onPressed: onAddFriendTap,
            child: const Text('Ajouter'),
          ),

        // Display logout button if onLogoutTap is provided
        if (onLogoutTap != null)
          ElevatedButton(
            onPressed: onLogoutTap,
            child: const Text('Logout'),
          ),

        // Other profile details
        // ...
      ],
    );
  }
}
