import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/create_team_view_model.dart';
import '../widgets/molecules/custom_search_bar.dart';
import '../widgets/atoms/texts/custom_text_field.dart';

class CreateTeamScreen extends StatelessWidget {
  const CreateTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateTeamViewModel>(
      create: (_) => CreateTeamViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Team'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Go back to TeamsScreen
            },
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage!)),
                  );
                  viewModel.resetStatus();
                } else if (viewModel.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.successMessage!)),
                  );
                  viewModel.resetStatus();

                  // Optionally navigate back to TeamsScreen
                  Navigator.pop(context);
                }
              });

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Team Image with Upload Functionality
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: viewModel.teamImage != null
                                  ? MemoryImage(viewModel.teamImage!)
                                  : const NetworkImage(
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQx-RLO1096Hkl10EA9jQ6Il5_hQ3HtB2iIyg&s')
                                      as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  viewModel.pickTeamImage();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Team Name Input Field
                        CustomTextField(
                          controller: viewModel.teamNameController,
                          hintText: 'Enter team name',
                        ),
                        const SizedBox(height: 20),
                        // Search Bar for Friends
                        CustomSearchBar(
                          controller: viewModel.searchController,
                          hintText: 'Search friends',
                        ),
                        const SizedBox(height: 10),
                        // Display Search Results
                        if (viewModel.isSearching) ...[
                          const CircularProgressIndicator(),
                        ] else if (viewModel.searchResults.isNotEmpty) ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.searchResults.length,
                            itemBuilder: (context, index) {
                              final user = viewModel.searchResults[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePictureUrl),
                                ),
                                title: Text(user.username),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    viewModel.addFriend(user);
                                  },
                                ),
                              );
                            },
                          ),
                        ] else if (!viewModel.isSearching &&
                            viewModel.searchController.text.isNotEmpty) ...[
                          const Center(
                            child: Text(
                              'No users found.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        // Display Selected Friends
                        if (viewModel.selectedFriends.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: viewModel.selectedFriends.map((friend) {
                              bool isCurrentUser =
                                  friend.uid == viewModel.currentUser?.uid;
                              return Chip(
                                avatar: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(friend.profilePictureUrl),
                                ),
                                label: Text(friend.username),
                                onDeleted: isCurrentUser
                                    ? null
                                    : () {
                                        viewModel.removeFriend(friend);
                                      },
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 20),
                        // Create Team Button
                        ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () {
                                  // Implement create team functionality
                                  viewModel.createTeam();
                                },
                          child: const Text('Create Team'),
                        ),
                      ],
                    ),
                  ),
                  if (viewModel.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
