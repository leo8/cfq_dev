import 'package:flutter/material.dart';
import '../../models/user.dart' as model;
import '../molecules/avatar_neon_switch.dart';
import '../atoms/avatars/clickable_avatar.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/colors.dart';

class ActiveFriendsList extends StatelessWidget {
  final model.User currentUser;
  final List<model.User> activeFriends;
  final List<model.User> inactiveFriends;
  final Function(bool) onActiveChanged;
  final Function(String) onFriendTap;

  const ActiveFriendsList({
    super.key,
    required this.currentUser,
    required this.activeFriends,
    required this.inactiveFriends,
    required this.onActiveChanged,
    required this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildUserAvatar(currentUser),
          ...activeFriends.map((friend) => _buildFriendAvatar(friend, true)),
          ...inactiveFriends.map((friend) => _buildFriendAvatar(friend, false)),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(model.User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 14.0),
      child: Column(
        children: [
          AvatarNeonSwitch(
            imageUrl: user.profilePictureUrl,
            isActive: user.isActive,
            onChanged: onActiveChanged,
            avatarRadius: 38,
            switchSize: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar(model.User friend, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 14.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? CustomColor.turnColor : CustomColor.offColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? CustomColor.turnColor.withOpacity(0.5)
                      : CustomColor.offColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClickableAvatar(
              userId: friend.uid,
              imageUrl: friend.profilePictureUrl,
              radius: 38,
              onTap: () => onFriendTap(friend.uid),
              isActive: friend.isActive,
            ),
          ),
          const SizedBox(height: 4),
          Text(friend.username, style: CustomTextStyle.miniBody),
        ],
      ),
    );
  }
}
