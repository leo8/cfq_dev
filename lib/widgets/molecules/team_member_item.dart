import 'package:flutter/material.dart';
import '../atoms/texts/custom_text.dart';
import '../../models/user.dart' as model;
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../atoms/avatars/clickable_avatar.dart';
import '../../screens/profile_screen.dart';

class TeamMemberItem extends StatelessWidget {
  final model.User user;
  final bool isCurrentUser;

  const TeamMemberItem({
    super.key,
    required this.user,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
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
              if (isCurrentUser)
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CustomColor.greenColor,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          CustomText(
            text: isCurrentUser ? 'You' : user.username,
            color: CustomColor.white,
            fontSize: CustomFont.fontSize12,
            fontWeight: CustomFont.fontWeightBold,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
