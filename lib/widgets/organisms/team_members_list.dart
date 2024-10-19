import 'package:flutter/material.dart';
import '../molecules/team_member_item.dart';
import '../../models/user.dart' as model;
import '../../utils/styles/colors.dart';

class TeamMembersList extends StatelessWidget {
  final List<model.User> members;
  final bool isCurrentUserActive;

  const TeamMembersList({
    super.key,
    required this.members,
    required this.isCurrentUserActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1,
          color: CustomColor.customWhite,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
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
                  isCurrentUserActive: index == 0 ? isCurrentUserActive : null,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 1,
          color: CustomColor.customWhite,
        ),
      ],
    );
  }
}
