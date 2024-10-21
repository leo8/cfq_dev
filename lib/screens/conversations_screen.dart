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
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation =
                          viewModel.filteredConversations[index];
                      return ConversationCard(conversation: conversation);
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
