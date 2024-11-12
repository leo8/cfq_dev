import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/teams_view_model.dart';
import 'create_team_screen.dart';
import '../models/team.dart';
import '../widgets/atoms/buttons/outlined_icon_button.dart';
import '../utils/styles/text_styles.dart';
import 'team_details_screen.dart';
import '../widgets/organisms/team_card.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../utils/styles/string.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/colors.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key, required this.currentUserId});
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeamsViewModel>(
      create: (_) => TeamsViewModel(currentUserId),
      child: Consumer<TeamsViewModel>(
        builder: (context, viewModel, child) {
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Scaffold(
                backgroundColor: CustomColor.transparent,
                appBar: AppBar(
                  toolbarHeight: 40,
                  automaticallyImplyLeading: false,
                  backgroundColor: CustomColor.customBlack,
                  surfaceTintColor: CustomColor.customBlack,
                ),
                body: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Center(
                            child: Text(
                              CustomString.myTeamsCapital,
                              style: CustomTextStyle.hugeTitle
                                  .copyWith(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Center(
                                  child: OutlinedIconButton(
                                    icon: CustomIcon.add,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateTeamScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 25),
                              ],
                            ),
                          ),
                          Expanded(
                            child: viewModel.teams.isEmpty
                                ? Center(
                                    child: CustomText(
                                      text: CustomString.noTeamsYet,
                                      textStyle: CustomTextStyle.body1,
                                    ),
                                  )
                                : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    itemCount: viewModel.teams.length,
                                    itemBuilder: (context, index) {
                                      Team team = viewModel.teams[index];
                                      final members =
                                          viewModel.teamMembers[team.uid] ?? [];
                                      return TeamCard(
                                        team: team,
                                        members: members,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TeamDetailsScreen(team: team),
                                            ),
                                          );
                                        },
                                      );
                                    },
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
