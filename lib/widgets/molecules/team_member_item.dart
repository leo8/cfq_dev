import 'package:flutter/material.dart';
import '../atoms/texts/custom_text.dart';
import '../../models/user.dart' as model;
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/string.dart';
import '../atoms/avatars/clickable_avatar.dart';
import '../../screens/profile_screen.dart';

class TeamMemberItem extends StatelessWidget {
  final model.User user;
  final bool isCurrentUser;
  final bool? isCurrentUserActive;

  const TeamMemberItem({
    super.key,
    required this.user,
    required this.isCurrentUser,
    this.isCurrentUserActive,
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
              if (isCurrentUser && isCurrentUserActive != null)
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrentUserActive!
                          ? CustomColor.turnColor
                          : CustomColor.offColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrentUserActive!
                            ? CustomColor.turnColor.withOpacity(0.5)
                            : CustomColor.offColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
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
                isActive: user.isActive,
              ),
              if (isCurrentUser && isCurrentUserActive == null)
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CustomColor.green,
                      width: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          CustomText(
            text: isCurrentUser ? CustomString.you : user.username,
            textStyle: CustomTextStyle.miniBody,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
