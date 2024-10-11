import 'package:flutter/material.dart';
import '../../models/team.dart';
import '../../models/user.dart' as model;
import '../atoms/avatars/custom_avatar.dart';
import '../atoms/texts/custom_text.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/Colors.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final List<model.User> members;
  final VoidCallback onTap;

  const TeamCard({
    super.key,
    required this.team,
    required this.members,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: CustomColor.black,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: CustomColor.white24, width: 1.0),
        ),
        child: Row(
          children: [
            CustomAvatar(
              imageUrl: team.imageUrl,
              radius: 35,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: team.name,
                    textStyle: CustomTextStyle.title1,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMemberAvatars(),
                      const SizedBox(width: 8),
                      CustomText(
                          text: members.length.toString() +
                              CustomString.space +
                              CustomString.members,
                          textStyle: CustomTextStyle.body1),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              CustomIcon.arrowForward,
              color: CustomColor.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatars() {
    return SizedBox(
      width: 80,
      height: 40,
      child: Stack(
        children: members.take(3).toList().asMap().entries.map((entry) {
          int idx = entry.key;
          model.User member = entry.value;
          return Positioned(
            left: idx * 24.0,
            child: CustomAvatar(
              imageUrl: member.profilePictureUrl,
              radius: 12,
              borderColor: CustomColor.white,
              borderWidth: 2,
            ),
          );
        }).toList(),
      ),
    );
  }
}
