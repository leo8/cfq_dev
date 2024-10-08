import 'package:flutter/material.dart';
import '../../../models/team.dart';
import '../../../utils/styles/colors.dart';

class TeamSelectionDropdown extends StatelessWidget {
  final List<Team> teams;
  final Function(Team) onTeamSelected;

  const TeamSelectionDropdown({
    Key? key,
    required this.teams,
    required this.onTeamSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Team>(
        icon: const Icon(Icons.arrow_drop_down, color: CustomColor.white),
        dropdownColor: CustomColor.mobileBackgroundColor,
        hint: const Text('Select a team',
            style: TextStyle(color: CustomColor.white70)),
        items: teams.map((Team team) {
          return DropdownMenuItem<Team>(
            value: team,
            child: Text(team.name,
                style: const TextStyle(color: CustomColor.white)),
          );
        }).toList(),
        onChanged: (Team? newValue) {
          if (newValue != null) {
            onTeamSelected(newValue);
          }
        },
      ),
    );
  }
}
