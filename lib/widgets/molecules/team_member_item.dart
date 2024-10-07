import 'package:flutter/material.dart';
import '../atoms/texts/custom_text.dart';
import '../../models/user.dart' as model;
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../atoms/avatars/clickable_avatar.dart';
import '../../screens/profile_screen.dart';

class TeamMemberItem extends StatelessWidget {
  final model.User user;

  const TeamMemberItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClickableAvatar(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: user.uid),
                ),
              );
            },
            userId: user.uid,
            imageUrl: user.profilePictureUrl,
            radius: 30,
          ),
          const SizedBox(height: 5),
          CustomText(
            text: user.username,
            color: CustomColor.white,
            fontSize: CustomFont.fontSize12,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
