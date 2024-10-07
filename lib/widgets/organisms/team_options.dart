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
  final VoidCallback onTeamLeft;

  const TeamOptions({
    super.key,
    required this.team,
    required this.onTeamLeft,
  });

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
        _buildOptionButton(
          context,
          icon: Icons.exit_to_app,
          label: 'Quitter',
          onPressed: () async {
            bool confirmed = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Quitter l\'équipe'),
                  content: const Text(
                      'Êtes-vous sûr de vouloir quitter cette équipe ?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Annuler'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Quitter'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (confirmed) {
              bool success = await viewModel.leaveTeam();
              if (success) {
                onTeamLeft();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Erreur lors de la sortie de l\'équipe')),
                );
              }
            }
          },
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
