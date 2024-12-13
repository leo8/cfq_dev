import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../utils/styles/icons.dart';
import '../widgets/atoms/texts/custom_text.dart';
import '../widgets/atoms/search_bars/custom_search_bar.dart';
import '../models/user.dart' as model;
import '../view_models/thread_view_model.dart';
import 'profile_screen.dart';
import '../widgets/atoms/avatars/custom_avatar.dart';

class SearchScreen extends StatefulWidget {
  final ThreadViewModel viewModel;

  const SearchScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Perform initial search with empty string
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.performSearch('');
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.viewModel.performSearch(_searchController.text);
  }

  bool isFriend(String userId) {
    // Assuming you have a list of friend IDs in your viewModel
    return widget.viewModel.currentUser!.friends.contains(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customBlack,
      appBar: AppBar(
        backgroundColor: CustomColor.customBlack,
        surfaceTintColor: CustomColor.customBlack,
        elevation: 0,
        leading: IconButton(
          icon: CustomIcon.arrowBack,
          onPressed: () {
            widget.viewModel.clearSearchResults();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: CustomSearchBar(
                  controller: _searchController,
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: widget.viewModel,
              builder: (context, child) {
                if (widget.viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (widget.viewModel.users.isEmpty) {
                  return const Center(
                    child: CustomText(
                      text: CustomString.noUsersFound,
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: widget.viewModel.users.length,
                    itemBuilder: (context, index) {
                      model.User user = widget.viewModel.users[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(userId: user.uid),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: CustomColor.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              isFriend(user.uid)
                                  ? Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: user.isActive
                                            ? [
                                                const BoxShadow(
                                                  color: CustomColor.turnColor,
                                                  blurRadius: 5,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundImage:
                                            CustomCachedImageProvider
                                                .withCacheManager(
                                          imageUrl: user.profilePictureUrl,
                                        ),
                                      ),
                                    )
                                  : CustomAvatar(
                                      imageUrl: user.profilePictureUrl,
                                      radius: 24,
                                    ),
                              const SizedBox(width: 16),
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
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
