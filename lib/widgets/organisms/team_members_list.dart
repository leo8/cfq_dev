import 'package:flutter/material.dart';
import '../molecules/team_member_item.dart';
import '../../models/user.dart' as model;
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class TeamMembersList extends StatelessWidget {
  final List<model.User> members;

  const TeamMembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Team Members',
          style: TextStyle(
            color: CustomColor.white,
            fontSize: CustomFont.fontSize20,
            fontWeight: CustomFont.fontWeightBold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                model.User user = members[index];
                return TeamMemberItem(
                  user: user,
                  isCurrentUser: index == 0,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
