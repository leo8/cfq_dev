import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart' as model;
import '../../view_models/add_team_members_view_model.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';

class AddTeamMembersScreen extends StatelessWidget {
  final String teamId;

  const AddTeamMembersScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTeamMembersViewModel(teamId: teamId),
      child: Consumer<AddTeamMembersViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 40,
              backgroundColor: CustomColor.transparent,
              elevation: 0,
              leading: IconButton(
                  icon: CustomIcon.arrowBack,
                  onPressed: () {
                    Navigator.of(context).pop(viewModel.hasChanges);
                  }),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      _buildMembersList(
                        CustomString.teamMembers,
                        viewModel.teamMembers,
                        viewModel,
                        true,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      _buildMembersList(
                        CustomString.otherFriends,
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
            style: CustomTextStyle.body1.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...users.map(
          (user) => Column(
            children: [
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePictureUrl),
                ),
                title: Text(user.username),
                trailing: isTeamMember
                    ? const Icon(Icons.check_circle, color: CustomColor.green)
                    : ElevatedButton(
                        onPressed: () => viewModel.addMemberToTeam(user.uid),
                        child: const Text(CustomString.addFriend),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
