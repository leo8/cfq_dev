import 'package:cfq_dev/widgets/atoms/buttons/turn_button.dart';
import '../atoms/buttons/cfq_button.dart';
import 'package:flutter/material.dart';
import '../molecules/team_option_button.dart';
import '../../utils/styles/colors.dart';
import '../../screens/add_team_members_screen.dart';
import '../../models/team.dart';
import '../../view_models/team_details_view_model.dart';
import 'package:provider/provider.dart';

class TeamOptions extends StatelessWidget {
  final Team team;

  const TeamOptions({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TeamDetailsViewModel>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOptionButton(
          context,
          icon: Icons.person_add,
          label: 'Ajouter',
          onPressed: () async {
            final bool? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTeamMembersScreen(teamId: team.uid),
              ),
            );
            if (result == true) {
              await viewModel.refreshTeamDetails();
            }
          },
        ),
        TurnButton(),
        CfqButton(),
        TeamOptionButton(
          icon: Icons.exit_to_app,
          label: 'Quitter',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildOptionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: CustomColor.white),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(color: CustomColor.white),
        ),
      ],
    );
  }
}
