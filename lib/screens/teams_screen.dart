import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/teams_view_model.dart';
import 'create_team_screen.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/atoms/buttons/outlined_icon_button.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';
import 'team_details_screen.dart';
import '../widgets/molecules/team_card.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../utils/styles/string.dart';
import '../../utils/styles/icons.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeamsViewModel>(
      create: (_) => TeamsViewModel(),
      child: Consumer<TeamsViewModel>(builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(CustomString.mesTeams),
          ),
          body: RefreshIndicator(
            onRefresh: () => viewModel.fetchTeams(),
            child: Consumer<TeamsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    children: [
                      // Create Team Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Centered OutlinedIconButton
                            Center(
                              child: OutlinedIconButton(
                                icon: CustomIcon.add,
                                onPressed: () {
                                  // Navigate to CreateTeamScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateTeamScreen(),
                                    ),
                                  ).then((_) {
                                    // Refresh teams after returning
                                    viewModel.fetchTeams();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Text 'Créer une team' below the button
                            const CustomText(
                              text: CustomString.createTeam,
                              fontSize: CustomFont.fontSize18,
                              color: CustomColor.white,
                            ),
                          ],
                        ),
                      ),
                      // Teams List
                      Expanded(
                        child: viewModel.teams.isEmpty
                            ? const Center(
                                child: CustomText(
                                  text: CustomString.noTeamsYet,
                                  color: CustomColor.white,
                                  fontSize: CustomFont.fontSize18,
                                ),
                              )
                            : ListView.builder(
                                itemCount: viewModel.teams.length,
                                itemBuilder: (context, index) {
                                  Team team = viewModel.teams[index];
                                  return FutureBuilder<List<model.User>>(
                                    future: _fetchTeamMembers(team.members),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox();
                                      } else if (snapshot.hasData) {
                                        List<model.User> members =
                                            snapshot.data!;
                                        return TeamCard(
                                          team: team,
                                          members: members,
                                          onTap: () async {
                                            final bool? result =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TeamDetailsScreen(
                                                        team: team),
                                              ),
                                            );
                                            if (result == true) {
                                              await viewModel.fetchTeams();
                                            }
                                          },
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Future<List<model.User>> _fetchTeamMembers(List memberUids) async {
    // Firestore limits 'whereIn' queries to 10 items
    List<model.User> allMembers = [];

    List<List> chunks = [];
    for (var i = 0; i < memberUids.length; i += 10) {
      chunks.add(memberUids.sublist(
          i, i + 10 > memberUids.length ? memberUids.length : i + 10));
    }

    for (var chunk in chunks) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: chunk)
          .get();

      allMembers.addAll(
          snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList());
    }

    return allMembers;
  }
}
