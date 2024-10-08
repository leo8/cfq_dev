import 'package:flutter/material.dart';
import '../atoms/chips/invitee_chip.dart';
import '../atoms/chips/team_chip.dart';
import '../molecules/invitee_search_result_item.dart';
import '../atoms/search_bars/invitee_search_bar.dart';
import '../../models/user.dart' as model;
import '../../models/team.dart';

class InviteesField extends StatelessWidget {
  final List<model.User> selectedInvitees;
  final List<Team> selectedTeams;
  final List<model.User> searchResults;
  final TextEditingController searchController;
  final bool isSearching;
  final Function(model.User) onAddInvitee;
  final Function(model.User) onRemoveInvitee;
  final Function(Team) onAddTeam;
  final Function(Team) onRemoveTeam;
  final List<Team> userTeams;
  final VoidCallback onSelectEverybody;

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
    required this.userTeams,
    required this.onSelectEverybody,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar with Team Selection and Everybody option
        InviteeSearchBar(
          controller: searchController,
          onSearch: () {},
          userTeams: userTeams,
          onTeamSelected: onAddTeam,
          onSelectEverybody: onSelectEverybody,
        ),
        const SizedBox(height: 10),
        // Display Selected Invitees and Teams
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            ...selectedInvitees.map((invitee) {
              return InviteeChip(
                invitee: invitee,
                onDelete: () => onRemoveInvitee(invitee),
              );
            }),
            ...selectedTeams.map((team) {
              return TeamChip(
                team: team,
                onDelete: () => onRemoveTeam(team),
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        // Display Search Results
        if (isSearching)
          const CircularProgressIndicator()
        else
          Container(
            constraints: const BoxConstraints(
              maxHeight: 150.0,
            ),
            child: searchResults.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      return InviteeSearchResultItem(
                        user: user,
                        onAdd: () => onAddInvitee(user),
                      );
                    },
                  )
                : searchController.text.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No users found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
