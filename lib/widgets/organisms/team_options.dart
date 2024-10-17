import 'package:cfq_dev/widgets/atoms/buttons/turn_button.dart';
import '../atoms/buttons/cfq_button.dart';
import 'package:flutter/material.dart';
import '../../screens/add_team_members_screen.dart';
import '../../models/team.dart';
import '../../view_models/team_details_view_model.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart' as model;
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/utils.dart';

class TeamOptions extends StatelessWidget {
  final Team team;
  final VoidCallback onTeamLeft;
  final List<model.User>? prefillMembers;
  final Team? prefillTeam;

  const TeamOptions({
    super.key,
    required this.team,
    required this.onTeamLeft,
    this.prefillMembers,
    this.prefillTeam,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TeamDetailsViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  context,
                  icon: CustomIcon.addMember,
                  label: CustomString.add,
                  onPressed: () async {
                    final bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTeamMembersScreen(teamId: team.uid),
                      ),
                    );
                    if (result == true) {
                      await viewModel.refreshTeamDetails();
                    }
                  },
                ),
                CfqButton(
                  prefillTeam: team,
                  prefillMembers: viewModel.members,
                ),
                TurnButton(
                  prefillTeam: team,
                  prefillMembers: viewModel.members,
                ),
                _buildOptionButton(
                  context,
                  icon: CustomIcon.leaveTeam,
                  label: CustomString.leave,
                  onPressed: () async {
                    bool confirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(CustomString.leaveTeam),
                          content: const Text(CustomString.sureToLeaveTeam),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(CustomString.cancel),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: const Text(CustomString.leave),
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
                        showSnackBar(CustomString.errorLeavingTeam, context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      {required CustomIcon icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      children: [
        IconButton(
          icon: icon.copyWith(size: 28),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: CustomTextStyle.body2,
        ),
      ],
    );
  }
}
