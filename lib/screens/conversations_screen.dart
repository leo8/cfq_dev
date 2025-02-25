import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/conversations_view_model.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../widgets/atoms/search_bars/custom_search_bar.dart';
import '../widgets/organisms/conversation_card.dart';
import '../models/user.dart' as model;
import '../models/conversation.dart';
import 'conversation_screen.dart';
import '../utils/loading_overlay.dart';

class ConversationsScreen extends StatelessWidget {
  final model.User currentUser;

  const ConversationsScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationsViewModel>(
      builder: (context, viewModel, child) {
        return LoadingOverlay(
          isLoading: viewModel.isLoading,
          child: Scaffold(
            backgroundColor: CustomColor.customBlack,
            appBar: AppBar(
              toolbarHeight: 60,
              backgroundColor: CustomColor.customBlack,
              surfaceTintColor: CustomColor.customBlack,
              leading: IconButton(
                icon: CustomIcon.arrowBack,
                onPressed: () async {
                  final viewModel = Provider.of<ConversationsViewModel>(context,
                      listen: false);
                  await viewModel.setLoadingState(true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  await viewModel.setLoadingState(false);
                },
              ),
              title: Text(
                CustomString.messagerieCapital,
                style: CustomTextStyle.bigBody1,
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomSearchBar(
                    controller: viewModel.searchController,
                    onChanged: (value) => viewModel.searchConversations(value),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildConversationsList(
                      viewModel.conversations, viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConversationsList(
      List<Conversation> conversations, ConversationsViewModel viewModel) {
    if (conversations.isEmpty) {
      return const Center(child: Text(CustomString.noConversationsYet));
    }
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: ConversationCard(
              key: ValueKey(conversations[index].id),
              currentUserUsername: currentUser.username,
              conversation: conversations[index],
              unreadMessagesCount:
                  viewModel.getUnreadMessagesCount(conversations[index].id)),
          onTap: () => _navigateToConversation(context, conversations[index]),
        );
      },
    );
  }

  void _navigateToConversation(
      BuildContext context, Conversation conversation) {
    final viewModel =
        Provider.of<ConversationsViewModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          channelId: conversation.id,
          eventName: conversation.name,
          members: conversation.members,
          organizerId: conversation.organizerId,
          organizerName: conversation.organizerName,
          organizerProfilePicture: conversation.organizerProfilePicture,
          currentUser: currentUser,
          addConversationToUserList: viewModel.addConversationToUserList,
          removeConversationFromUserList:
              viewModel.removeConversationFromUserList,
          initialIsInUserConversations: true,
          eventPicture: conversation.imageUrl,
          resetUnreadMessages: viewModel.resetUnreadMessages,
        ),
      ),
    );
  }
}
