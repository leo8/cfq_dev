import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';
import '../../../models/team.dart';
import '../../../models/user.dart' as model;
import '../../../utils/styles/string.dart';

class InviteeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;
  final List<dynamic> searchResults;
  final Function(model.User) onAddInvitee;
  final Function(Team) onAddTeam;
  final VoidCallback onSelectEverybody;
  final bool isEverybodySelected;

  const InviteeSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search friends or teams to invite',
    required this.searchResults,
    required this.onAddInvitee,
    required this.onAddTeam,
    required this.onSelectEverybody,
    required this.isEverybodySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: searchResults.length + (isEverybodySelected ? 0 : 1),
            itemBuilder: (context, index) {
              if (!isEverybodySelected && index == 0) {
                // "Tout le monde" option
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/turn_button.png'),
                  ),
                  title: const Text(CustomString.toutLeMonde),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onSelectEverybody,
                  ),
                );
              } else {
                final result = isEverybodySelected
                    ? searchResults[index]
                    : searchResults[index - 1];
                if (result is Team) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(result.imageUrl),
                    ),
                    title: Text(result.name),
                    subtitle: const Text(CustomString.team),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
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
                      icon: const Icon(Icons.add),
                      onPressed: () => onAddInvitee(result),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        )
    ]);
  }
}
