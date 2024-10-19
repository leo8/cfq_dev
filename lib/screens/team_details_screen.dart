import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../view_models/team_details_view_model.dart';
import '../widgets/organisms/team_header.dart';
import '../widgets/organisms/team_options.dart';
import '../utils/styles/colors.dart';
import '../widgets/organisms/team_members_list.dart';
import '../../utils/styles/icons.dart';

class TeamDetailsScreen extends StatelessWidget {
  final Team team;

  const TeamDetailsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamDetailsViewModel(team: team),
      child: Consumer<TeamDetailsViewModel>(
        builder: (context, viewModel, child) {
          return NeonBackground(
            child: Scaffold(
              backgroundColor: CustomColor.transparent,
              appBar: AppBar(
                toolbarHeight: 40,
                backgroundColor: CustomColor.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: CustomIcon.arrowBack,
                  onPressed: () {
                    Navigator.of(context).pop(viewModel.hasChanges);
                  },
                ),
              ),
              body: SafeArea(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            TeamHeader(team: viewModel.team),
                            const SizedBox(height: 20),
                            TeamOptions(
                              team: viewModel.team,
                              onTeamLeft: () {
                                Navigator.of(context).pop(true);
                              },
                              prefillMembers: viewModel.members,
                              prefillTeam: viewModel.team,
                            ),
                            const SizedBox(height: 20),
                            TeamMembersList(
                              members: viewModel.members,
                              isCurrentUserActive:
                                  viewModel.isCurrentUserActive,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
