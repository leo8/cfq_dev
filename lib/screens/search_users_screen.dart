import 'package:cfq_dev/models/user.dart';
import 'package:cfq_dev/view_models/search_users_view_model.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:cfq_dev/widgets/molecules/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';

class SearchUsersScreen extends StatelessWidget {
  const SearchUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchUsersViewModel>(
      create: (context) => SearchUsersViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Users'),
          backgroundColor: CustomColor.mobileBackgroundColor,
        ),
        body: Consumer<SearchUsersViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomSearchBar(
                    controller: viewModel.searchController,
                  ),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.users.isEmpty
                          ? const SizedBox()
                          : ListView.builder(
                              itemCount: viewModel.users.length,
                              itemBuilder: (context, index) {
                                User user = viewModel.users[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Handle tap (currently does nothing)
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: CustomColor.white24,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      children: [
                                        // Profile image
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage: NetworkImage(
                                              user.profilePictureUrl),
                                        ),
                                        const SizedBox(width: 16),
                                        // Username
                                        CustomText(
                                          text: user.username,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
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
          },
        ),
      ),
    );
  }
}
