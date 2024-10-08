import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';
import '../../molecules/team_selection_dropdown.dart';
import '../../../models/team.dart';

class InviteeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String hintText;
  final List<Team> userTeams;
  final Function(Team) onTeamSelected;
  final VoidCallback onSelectEverybody;

  const InviteeSearchBar({
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search friends to invite',
    required this.userTeams,
    required this.onTeamSelected,
    required this.onSelectEverybody,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: (value) => onSearch(),
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TeamSelectionDropdown(
              teams: userTeams,
              onTeamSelected: onTeamSelected,
            ),
            TextButton(
              onPressed: onSelectEverybody,
              child: const Text('Everybody',
                  style: TextStyle(color: CustomColor.white)),
            ),
          ],
        ),
      ],
    );
  }
}
