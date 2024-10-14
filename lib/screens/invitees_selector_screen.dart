import 'package:flutter/material.dart';
import '../widgets/molecules/invitees_field.dart';
import '../models/user.dart' as model;
import '../models/team.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../utils/styles/text_styles.dart';

class InviteesSelectorScreen extends StatelessWidget {
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

  const InviteesSelectorScreen({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: IconButton(
          icon: CustomIcon.arrowBack,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: CustomColor.black,
        actions: [
          TextButton(
            onPressed: () {}, //onInvite
            child: Text(
              CustomString.publier,
              style: CustomTextStyle.title3
                  .copyWith(color: CustomColor.personnalizedPurple),
            ),
          ),
        ],
      ),
      body: InviteesField(
        searchController: searchController,
        selectedInvitees: selectedInvitees,
        selectedTeams: selectedTeams,
        searchResults: searchResults,
        isSearching: isSearching,
        onAddInvitee: onAddInvitee,
        onRemoveInvitee: onRemoveInvitee,
        onAddTeam: onAddTeam,
        onRemoveTeam: onRemoveTeam,
        onSelectEverybody: onSelectEverybody,
        onSearch: onSearch,
        isEverybodySelected: isEverybodySelected,
      ),
    );
  }
}
