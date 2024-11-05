import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart' as model;
import '../../view_models/add_team_members_view_model.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';
import '../widgets/atoms/search_bars/custom_search_bar.dart';

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
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: Text(CustomString.otherFriends,
                              style: CustomTextStyle.bigBody1),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomSearchBar(
                          controller: viewModel.searchController,
                          hintText: CustomString.searchFriends,
                          onChanged: (value) => viewModel.performSearch(value),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildMembersList(
                        '',
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
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(title, style: CustomTextStyle.bigBody1),
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
                    : FutureBuilder<model.Request?>(
                        future: viewModel.getExistingRequest(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 85,
                              height: 36,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }

                          final request = snapshot.data;
                          if (request?.status == model.RequestStatus.pending) {
                            return Container(
                              width: 85,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: CustomColor.customDarkGrey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'En attente',
                                style: CustomTextStyle.body2.copyWith(
                                  color: CustomColor.grey300,
                                ),
                              ),
                            );
                          }

                          return ElevatedButton(
                            onPressed: () =>
                                viewModel.addMemberToTeam(user.uid),
                            child: const Text(CustomString.addFriend),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
