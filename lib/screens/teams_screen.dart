// teams_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/teams_view_model.dart';
import 'create_team_screen.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/atoms/buttons/outlined_icon_button.dart'; // Import the OutlinedIconButton
import '../utils/styles/colors.dart'; // Import your custom colors
import '../utils/styles/fonts.dart'; // Import your custom fonts
import 'team_details_screen.dart'; // Import the TeamDetailsScreen

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeamsViewModel>(
      create: (_) => TeamsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teams'),
        ),
        body: Consumer<TeamsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Column(
                children: [
                  // Create Team Button with OutlinedIconButton
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Centered OutlinedIconButton
                        Center(
                          child: OutlinedIconButton(
                            icon: Icons.add,
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
                        const Text(
                          'Créer une team',
                          style: TextStyle(
                            fontSize: CustomFont.fontSize18,
                            color: CustomColor.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Conditional rendering of teams list or message
                  Expanded(
                    child: viewModel.teams.isEmpty
                        ? Center(
                            child: Text(
                              'Vous n\'avez pas encore de teams.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: viewModel.teams.length,
                            itemBuilder: (context, index) {
                              Team team = viewModel.teams[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to TeamDetailsScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TeamDetailsScreen(team: team),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Team Name
                                            Text(
                                              team.name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    24, // Larger font size
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            // Members Avatars and Count
                                            FutureBuilder(
                                              future: _fetchTeamMembers(
                                                  team.members),
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          List<model.User>>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const SizedBox();
                                                } else if (snapshot.hasData) {
                                                  List<model.User> members =
                                                      snapshot.data!;
                                                  int totalMembers =
                                                      members.length;

                                                  return Column(
                                                    children: [
                                                      // Overlapping Avatars
                                                      Center(
                                                        child: SizedBox(
                                                          height: 30,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            children: members
                                                                .take(3)
                                                                .asMap()
                                                                .entries
                                                                .map((entry) {
                                                              int idx =
                                                                  entry.key;
                                                              model.User
                                                                  member =
                                                                  entry.value;
                                                              return Positioned(
                                                                left:
                                                                    idx * 20.0,
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 15,
                                                                  backgroundColor:
                                                                      CustomColor
                                                                          .white,
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 13,
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            member.profilePictureUrl),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      // Total Members Count
                                                      Text(
                                                        '$totalMembers membres',
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  return const SizedBox();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Arrow Icon
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
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
