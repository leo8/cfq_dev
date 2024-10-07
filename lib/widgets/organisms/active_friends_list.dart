import 'package:flutter/material.dart';
import '../../models/user.dart' as model;
import '../molecules/avatar_neon_switch.dart';
import '../atoms/avatars/clickable_avatar.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class ActiveFriendsList extends StatelessWidget {
  final model.User currentUser;
  final List<model.User> activeFriends;
  final Function(bool) onActiveChanged;
  final Function(String) onFriendTap;

  const ActiveFriendsList({
    Key? key,
    required this.currentUser,
    required this.activeFriends,
    required this.onActiveChanged,
    required this.onFriendTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildUserAvatar(currentUser),
          ...activeFriends.map((friend) => _buildFriendAvatar(friend)),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(model.User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          AvatarNeonSwitch(
            imageUrl: user.profilePictureUrl,
            isActive: user.isActive,
            onChanged: onActiveChanged,
            avatarRadius: 45,
            switchSize: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar(model.User friend) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          ClickableAvatar(
            userId: friend.uid,
            imageUrl: friend.profilePictureUrl,
            radius: 45,
            onTap: () => onFriendTap(friend.uid),
          ),
          SizedBox(height: 4),
          Text(
            friend.username,
            style: TextStyle(
              color: CustomColor.white70,
              fontSize: CustomFont.fontSize12,
            ),
          ),
        ],
      ),
    );
  }
}
