import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/string.dart';
import '../view_models/cfq_invitees_view_model.dart';
import '../screens/profile_screen.dart';
import '../models/user.dart' as model;
import '../widgets/atoms/avatars/clickable_avatar.dart';
import '../utils/styles/neon_background.dart';

class CFQInviteesScreen extends StatelessWidget {
  final String cfqId;

  const CFQInviteesScreen({Key? key, required this.cfqId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CFQInviteesViewModel(cfqId: cfqId),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            backgroundColor: CustomColor.customBlack,
            surfaceTintColor: CustomColor.customBlack,
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
      labelStyle: CustomTextStyle.body1.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      unselectedLabelStyle: CustomTextStyle.body1,
      tabs: const [
        Tab(text: CustomString.followingUp),
        Tab(text: CustomString.invitees),
      ],
    );
  }

  Widget _buildTabBarView() {
    return Consumer<CFQInviteesViewModel>(
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
              _buildUserList(viewModel.followingUp),
              _buildUserList(viewModel.invitees),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<model.User> users) {
    return Consumer<CFQInviteesViewModel>(
      builder: (context, viewModel, child) {
        final currentUserId = viewModel.currentUserId;
        final currentUserIndex =
            users.indexWhere((user) => user.uid == currentUserId);

        if (currentUserIndex != -1) {
          final currentUser = users.removeAt(currentUserIndex);
          users.insert(0, currentUser);
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isCurrentUser = user.uid == currentUserId;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClickableAvatar(
                    userId: user.uid,
                    imageUrl: user.profilePictureUrl,
                    onTap: () {
                      if (!isCurrentUser) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(userId: user.uid),
                          ),
                        );
                      }
                    },
                    isActive:
                        viewModel.isFriend(user.uid) ? user.isActive : false,
                    radius: 40,
                  ),
                  const SizedBox(height: 4),
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
