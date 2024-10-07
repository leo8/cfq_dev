import 'package:flutter/material.dart';
import '../molecules/team_member_item.dart';
import '../../models/user.dart' as model;

class TeamMembersList extends StatelessWidget {
  final List members;

  const TeamMembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, index) {
          // Here you would fetch the user data based on the member ID
          // For now, we'll use placeholder data
          model.User user = model.User(
            username: 'User $index',
            profilePictureUrl: 'https://placeholder.com/150',
            uid: members[index],
            email: '',
            bio: '',
            friends: [],
            teams: [],
            location: '',
            birthDate: DateTime.now(),
            searchKey: '',
            isActive: true,
          );
          return TeamMemberItem(user: user);
        },
      ),
    );
  }
}