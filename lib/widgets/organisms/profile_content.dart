// profile_content.dart

import 'package:cfq_dev/widgets/molecules/friends_count.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:cfq_dev/utils/styles/fonts.dart';

class ProfileContent extends StatelessWidget {
  final model.User user;
  final bool isFriend;
  final bool isCurrentUser;
  final Function(bool)? onActiveChanged;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onAddFriendTap;
  final VoidCallback? onFriendsTap;

  const ProfileContent({
    required this.user,
    required this.isFriend,
    required this.isCurrentUser,
    this.onActiveChanged,
    this.onLogoutTap,
    this.onAddFriendTap,
    this.onFriendsTap,
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
          // Friends Count
          FriendsCount(
            friendsCount: user.friends.length,
            onFriendsTap: onFriendsTap ?? () {},
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
          // 'Ajouter' Button for Other Users (only if not friends)
          if (onAddFriendTap != null)
            ElevatedButton(
              onPressed: onAddFriendTap,
              child: Text('Ajouter'),
            ),
          // Lock Icon for Other Users
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: CustomColor.white24,
                child: Icon(
                  isFriend ? Icons.lock_open : Icons.lock,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
