// profile_content.dart

import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;

class ProfileContent extends StatelessWidget {
  final model.User user;
  final Function(bool)? onActiveChanged;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onAddFriendTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfileContent({
    required this.user,
    this.onActiveChanged,
    this.onLogoutTap,
    this.onAddFriendTap,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user.profilePictureUrl),
          ),
          SizedBox(height: 10),
          // Username
          Text(
            user.username,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          // Bio
          Text(
            user.bio,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          // Followers/Following Counts
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onFollowersTap,
                child: Column(
                  children: [
                    Text(
                      '${user.followers.length}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Followers'),
                  ],
                ),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: onFollowingTap,
                child: Column(
                  children: [
                    Text(
                      '${user.following.length}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Following'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // On/Off Switch for Current User
          if (onActiveChanged != null)
            SwitchListTile(
              title: Text('Active Status'),
              value: user.isActive,
              onChanged: onActiveChanged,
            ),
          // Logout Button for Current User
          if (onLogoutTap != null)
            ElevatedButton(
              onPressed: onLogoutTap,
              child: Text('Logout'),
            ),
          // 'Ajouter' Button for Other Users
          if (onAddFriendTap != null)
            ElevatedButton(
              onPressed: onAddFriendTap,
              child: Text('Ajouter'),
            ),
        ],
      ),
    );
  }
}
