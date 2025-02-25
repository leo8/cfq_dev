import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_team_view_model.dart';
import '../widgets/atoms/search_bars/custom_search_bar.dart';
import '../widgets/atoms/texts/bordered_icon_text_field.dart';
import '../widgets/atoms/buttons/custom_button.dart';
import '../utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/colors.dart';
import '../../utils/utils.dart';
import '../../utils/loading_overlay.dart';

class CreateTeamScreen extends StatelessWidget {
  const CreateTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateTeamViewModel>(
      create: (_) => CreateTeamViewModel(),
      child: Consumer<CreateTeamViewModel>(
        builder: (context, viewModel, child) => LoadingOverlay(
          isLoading: viewModel.isLoading,
          child: Scaffold(
            backgroundColor: CustomColor.customBlack,
            appBar: AppBar(
              toolbarHeight: 60,
              automaticallyImplyLeading: false,
              backgroundColor: CustomColor.customBlack,
              surfaceTintColor: CustomColor.customBlack,
              actions: [
                IconButton(
                  icon: CustomIcon.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              title: Text(
                CustomString.newTeamCapital,
                style: CustomTextStyle.title1,
              ),
            ),
            body: Consumer<CreateTeamViewModel>(
              builder: (context, viewModel, child) {
                if (!viewModel.isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Handle success and error messages
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (viewModel.errorMessage != null) {
                      showSnackBar(viewModel.errorMessage!, context);
                      viewModel.resetStatus();
                    } else if (viewModel.successMessage != null) {
                      showSnackBar(viewModel.successMessage!, context);
                      viewModel.resetStatus();
                      Navigator.pop(context);
                    }
                  });

                  return ListView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 75,
                                  backgroundColor: viewModel.teamImage != null
                                      ? null
                                      : CustomColor.customBlack,
                                  backgroundImage: viewModel.teamImage != null
                                      ? MemoryImage(viewModel.teamImage!)
                                      : null,
                                  child: viewModel.teamImage == null
                                      ? Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: CustomColor.customWhite,
                                              width: 0.5,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: IconButton(
                                      icon: CustomIcon.addImage,
                                      onPressed: () =>
                                          viewModel.pickTeamImage(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            BorderedIconTextField(
                              icon: CustomIcon.heart,
                              controller: viewModel.teamNameController,
                              hintText: CustomString.teamName,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => viewModel.performSearch(
                                  viewModel.searchController.text),
                              child: CustomSearchBar(
                                controller: viewModel.searchController,
                                hintText: CustomString.addFriends,
                                onChanged: (value) =>
                                    viewModel.performSearch(value),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                if (viewModel.isSearching) ...[
                                  const CircularProgressIndicator(),
                                ] else if (viewModel
                                    .searchResults.isNotEmpty) ...[
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: viewModel.searchResults.length,
                                    itemBuilder: (context, index) {
                                      final user =
                                          viewModel.searchResults[index];
                                      return ListTile(
                                        leading: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: user.isActive
                                                ? [
                                                    const BoxShadow(
                                                      color:
                                                          CustomColor.turnColor,
                                                      blurRadius: 5,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                user.profilePictureUrl),
                                          ),
                                        ),
                                        title: Text(user.username),
                                        trailing: IconButton(
                                          icon: CustomIcon.add,
                                          onPressed: () =>
                                              viewModel.addFriend(user),
                                        ),
                                      );
                                    },
                                  ),
                                ] else if (!viewModel.isSearching &&
                                    viewModel
                                        .searchController.text.isNotEmpty) ...[
                                  Center(
                                    child: Text(
                                      CustomString.noResults,
                                      style: CustomTextStyle.body2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (viewModel.selectedFriends.isNotEmpty)
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children:
                                      viewModel.selectedFriends.map((friend) {
                                    bool isCurrentUser = friend.uid ==
                                        viewModel.currentUser?.uid;
                                    return Chip(
                                      avatar: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            friend.profilePictureUrl),
                                      ),
                                      label: Text(friend.username),
                                      onDeleted: isCurrentUser
                                          ? null
                                          : () =>
                                              viewModel.removeFriend(friend),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: CustomButton(
                          label: CustomString.create,
                          onTap: () {
                            if (viewModel.selectedFriends.length <= 1) {
                              showSnackBar(
                                  CustomString.pleaseAddAtLeastOneMember,
                                  context);
                            } else {
                              viewModel.createTeam();
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
