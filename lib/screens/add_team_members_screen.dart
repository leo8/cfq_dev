import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart' as model;
import '../../view_models/add_team_members_view_model.dart';

class AddTeamMembersScreen extends StatelessWidget {
  final String teamId;

  const AddTeamMembersScreen({Key? key, required this.teamId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTeamMembersViewModel(teamId: teamId),
      child: Consumer<AddTeamMembersViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ajouter des membres'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop(viewModel.hasChanges);
                },
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: viewModel.friends.length,
                    itemBuilder: (context, index) {
                      model.User friend = viewModel.friends[index];
                      bool isTeamMember = viewModel.isTeamMember(friend.uid);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friend.profilePictureUrl),
                        ),
                        title: Text(friend.username),
                        trailing: isTeamMember
                            ? null
                            : ElevatedButton(
                                onPressed: () =>
                                    viewModel.addMemberToTeam(friend.uid),
                                child: const Text('Ajouter'),
                              ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
