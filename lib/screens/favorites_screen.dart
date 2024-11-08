import 'package:cfq_dev/utils/styles/neon_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/favorites_view_model.dart';
import '../widgets/organisms/events_list.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/text_styles.dart';

class FavoritesScreen extends StatelessWidget {
  final String currentUserId;

  const FavoritesScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesViewModel(currentUserId: currentUserId),
      child: NeonBackground(
        child: Scaffold(
          backgroundColor: CustomColor.transparent,
          appBar: AppBar(
            toolbarHeight: 40,
            backgroundColor: CustomColor.customBlack,
            surfaceTintColor: CustomColor.customBlack,
            leading: IconButton(
              icon: CustomIcon.arrowBack,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Consumer<FavoritesViewModel>(
            builder: (context, viewModel, child) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Center(
                          child: Text(
                            CustomString.favoritesCapital,
                            style: CustomTextStyle.body1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: EventsList(
                      eventsStream: viewModel.fetchFavoriteEventsStream(),
                      currentUser: viewModel.currentUser,
                      onFavoriteToggle: viewModel.toggleFavorite,
                      addConversationToUserList:
                          viewModel.addConversationToUserList,
                      removeConversationFromUserList:
                          viewModel.removeConversationFromUserList,
                      isConversationInUserList:
                          viewModel.isConversationInUserList,
                      resetUnreadMessages: viewModel.resetUnreadMessages,
                      addFollowUp: FavoritesViewModel.addFollowUp,
                      removeFollowUp: FavoritesViewModel.removeFollowUp,
                      isFollowingUpStream: viewModel.isFollowingUpStream,
                      toggleFollowUp: viewModel.toggleFollowUp,
                      onAttendingStatusChanged: viewModel.updateAttendingStatus,
                      attendingStatusStream: viewModel.attendingStatusStream,
                      attendingCountStream: viewModel.attendingCountStream,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
