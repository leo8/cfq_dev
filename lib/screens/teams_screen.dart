// teams_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/teams_view_model.dart';
import 'create_team_screen.dart';
import '../models/team.dart';
import '../models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';

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
            } else if (viewModel.teams.isEmpty) {
              return Center(
                child: Text(
                  'Vous n\'avez pas encore de teams.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: viewModel.teams.length,
                itemBuilder: (context, index) {
                  Team team = viewModel.teams[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to team details screen (not implemented)
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Team Image and Name
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(team.imageUrl),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  team.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Members Avatars and Count
                          FutureBuilder(
                            future: _fetchTeamMembers(team.members),
                            builder: (context,
                                AsyncSnapshot<List<model.User>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox();
                              } else if (snapshot.hasData) {
                                List<model.User> members = snapshot.data!;
                                return Row(
                                  children: [
                                    ...members.take(3).map(
                                          (member) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  member.profilePictureUrl),
                                            ),
                                          ),
                                        ),
                                    if (members.length > 3)
                                      Text(
                                        '+${members.length - 3}',
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
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to CreateTeamScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateTeamScreen(),
              ),
            ).then((_) {
              // Refresh teams after returning
              Provider.of<TeamsViewModel>(context, listen: false).fetchTeams();
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<List<model.User>> _fetchTeamMembers(List memberUids) async {
    // Fetch member user data
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: memberUids)
        .get();

    return snapshot.docs.map((doc) => model.User.fromSnap(doc)).toList();
  }
}
