import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';
import '../../../models/team.dart';
import '../../../models/user.dart' as model;

class InviteeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;
  final List<dynamic> searchResults;
  final Function(model.User) onAddInvitee;
  final Function(Team) onAddTeam;

  const InviteeSearchBar({
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search friends or teams to invite',
    required this.searchResults,
    required this.onAddInvitee,
    required this.onAddTeam,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onSearch,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: CustomColor.white),
            hintText: hintText,
            filled: true,
            fillColor: CustomColor.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (searchResults.isNotEmpty)
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                if (result is Team) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(result.imageUrl),
                    ),
                    title: Text(result.name),
                    subtitle: Text('Team'),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => onAddTeam(result),
                    ),
                  );
                } else if (result is model.User) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(result.profilePictureUrl),
                    ),
                    title: Text(result.username),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => onAddInvitee(result),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
      ],
    );
  }
}
