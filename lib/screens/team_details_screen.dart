import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../view_models/team_details_view_model.dart';
import '../widgets/organisms/team_header.dart';
import '../widgets/organisms/team_options.dart';
import '../utils/styles/colors.dart';
import '../widgets/organisms/team_members_list.dart';
import '../../utils/styles/icons.dart';
import '../utils/styles/text_styles.dart';

class TeamDetailsScreen extends StatelessWidget {
  final Team team;

  const TeamDetailsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamDetailsViewModel(team: team),
      child: Consumer<TeamDetailsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: CustomColor.mobileBackgroundColor,
            appBar: AppBar(
              title: Text(viewModel.team.name),
              backgroundColor: CustomColor.transparent,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(CustomIcon.arrowBack, color: CustomColor.white),
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
                          TeamMembersList(members: viewModel.members),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Team feed',
                              style: CustomTextStyle.getColoredTextStyle(
                                  CustomTextStyle.miniBody,
                                  CustomColor.pinkAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
