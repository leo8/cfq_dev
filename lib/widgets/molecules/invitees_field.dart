import 'package:flutter/material.dart';
import '../atoms/chips/invitee_chip.dart';
import '../atoms/chips/team_chip.dart';
import '../atoms/search_bars/invitee_search_bar.dart';
import '../../models/user.dart' as model;
import '../../models/team.dart';

class InviteesField extends StatelessWidget {
  final List<model.User> selectedInvitees;
  final List<Team> selectedTeams;
  final List<dynamic> searchResults;
  final TextEditingController searchController;
  final bool isSearching;
  final Function(model.User) onAddInvitee;
  final Function(model.User) onRemoveInvitee;
  final Function(Team) onAddTeam;
  final Function(Team) onRemoveTeam;
  final Function(String) onSearch;
  final VoidCallback onSelectEverybody;
  final bool isEverybodySelected;

  const InviteesField({
    required this.selectedInvitees,
    required this.selectedTeams,
    required this.searchResults,
    required this.searchController,
    required this.isSearching,
    required this.onAddInvitee,
    required this.onRemoveInvitee,
    required this.onAddTeam,
    required this.onRemoveTeam,
    required this.onSearch,
    required this.onSelectEverybody,
    required this.isEverybodySelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InviteeSearchBar(
          controller: searchController,
          onSearch: onSearch,
          searchResults: searchResults,
          onAddInvitee: onAddInvitee,
          onAddTeam: onAddTeam,
          onSelectEverybody: onSelectEverybody,
          isEverybodySelected: isEverybodySelected,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: [
            if (isEverybodySelected)
              Chip(
                avatar: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/turn_button.png'),
                ),
                label: Text('Tout le monde'),
                onDeleted: onSelectEverybody,
              ),
            ...selectedTeams.map((teamInvitee) => TeamChip(
                  team: teamInvitee,
                  onDelete: () => onRemoveTeam(teamInvitee),
                )),
            ...selectedInvitees.map((invitee) => InviteeChip(
                  invitee: invitee,
                  onDelete: () => onRemoveInvitee(invitee),
                )),
          ],
        ),
        if (isSearching) const CircularProgressIndicator(),
      ],
    );
  }
}
