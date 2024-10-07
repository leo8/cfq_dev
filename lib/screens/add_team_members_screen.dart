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
                : ListView(
                    children: [
                      _buildMembersList(
                        'Membres de l\'équipe',
                        viewModel.teamMembers,
                        viewModel,
                        true,
                      ),
                      _buildMembersList(
                        'Autres amis',
                        viewModel.nonTeamMembers,
                        viewModel,
                        false,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildMembersList(String title, List<model.User> users,
      AddTeamMembersViewModel viewModel, bool isTeamMember) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...users.map((user) => ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePictureUrl),
              ),
              title: Text(user.username),
              trailing: isTeamMember
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                      onPressed: () => viewModel.addMemberToTeam(user.uid),
                      child: const Text('Ajouter'),
                    ),
            )),
      ],
    );
  }
}
