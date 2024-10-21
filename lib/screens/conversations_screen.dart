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
import 'conversation_screen.dart';

class ConversationsScreen extends StatelessWidget {
  final model.User currentUser;

  const ConversationsScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationsViewModel(currentUser: currentUser),
      child: Scaffold(
        backgroundColor: CustomColor.customBlack,
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: CustomColor.customBlack,
          leading: IconButton(
            icon: CustomIcon.arrowBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Consumer<ConversationsViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    CustomString.messagerieCapital,
                    style: CustomTextStyle.body1.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomSearchBar(
                    controller: viewModel.searchController,
                    onChanged: (value) => viewModel.searchConversations(value),
                  ),
                ),
                const SizedBox(height: 20), // Added more space here
                Expanded(
                  child: viewModel.filteredConversations.isEmpty
                      ? Center(
                          child: Text(
                            CustomString.noConversationsYet,
                            style: CustomTextStyle.body1,
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conversation =
                                viewModel.filteredConversations[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConversationScreen(
                                      channelId: conversation.id,
                                      eventName: conversation.name,
                                      members: conversation.members,
                                      organizerName: conversation.organizerName,
                                      organizerProfilePicture:
                                          conversation.organizerProfilePicture,
                                      currentUser: currentUser,
                                      addConversationToUserList:
                                          viewModel.addConversationToUserList,
                                      removeConversationFromUserList: viewModel
                                          .removeConversationFromUserList,
                                      initialIsInUserConversations: true,
                                      eventPicture: conversation.imageUrl,
                                    ),
                                  ),
                                );
                              },
                              child:
                                  ConversationCard(conversation: conversation),
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
