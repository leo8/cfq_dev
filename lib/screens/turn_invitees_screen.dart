import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/string.dart';
import '../view_models/turn_invitees_view_model.dart';
import '../models/user.dart' as model;
import '../widgets/atoms/avatars/clickable_avatar.dart';
import '../utils/styles/neon_background.dart';

class TurnInviteesScreen extends StatelessWidget {
  final String turnId;

  const TurnInviteesScreen({Key? key, required this.turnId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TurnInviteesViewModel(turnId: turnId),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            backgroundColor: CustomColor.customBlack,
            actions: [
              IconButton(
                icon: CustomIcon.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Container(
            color: CustomColor.customBlack,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    CustomString.inviteesCapital,
                    style: CustomTextStyle.title1.copyWith(
                      color: CustomColor.customWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTabBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildTabBarView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      isScrollable: false,
      indicatorColor: CustomColor.customPurple,
      labelStyle: CustomTextStyle.bigBody1,
      unselectedLabelStyle: CustomTextStyle.body1,
      tabs: const [
        Tab(text: CustomString.attending),
        Tab(text: CustomString.notSureAttending),
        Tab(text: CustomString.notAttending),
        Tab(text: CustomString.invitees),
      ],
    );
  }

  Widget _buildTabBarView() {
    return Consumer<TurnInviteesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: CustomColor.customWhite,
            ),
          );
        }
        return NeonBackground(
          child: TabBarView(
            children: [
              _buildUserList(viewModel.attending),
              _buildUserList(viewModel.notSureAttending),
              _buildUserList(viewModel.notAttending),
              _buildUserList(viewModel.invitees),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<model.User> users) {
    return Consumer<TurnInviteesViewModel>(
      builder: (context, viewModel, child) {
        final currentUserId = viewModel.currentUserId;
        final currentUserIndex =
            users.indexWhere((user) => user.uid == currentUserId);

        if (currentUserIndex != -1) {
          final currentUser = users.removeAt(currentUserIndex);
          users.insert(0, currentUser);
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isCurrentUser = user.uid == currentUserId;

              return Column(
                children: [
                  ClickableAvatar(
                    userId: user.uid,
                    imageUrl: user.profilePictureUrl,
                    onTap: () {
                      // Implement navigation to user profile
                    },
                    isActive: user.isActive,
                    radius: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCurrentUser ? CustomString.you : user.username,
                    style: CustomTextStyle.body1
                        .copyWith(color: CustomColor.customWhite),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
