import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/organisms/turn_card_content.dart';
import '../widgets/organisms/cfq_card_content.dart';
import '../utils/logger.dart';
import '../view_models/expanded_card_view_model.dart';
import '../screens/conversation_screen.dart';

class ExpandedCardScreen extends StatelessWidget {
  final Widget cardContent;

  const ExpandedCardScreen({Key? key, required this.cardContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpandedCardViewModel(
        eventId: cardContent is TurnCardContent
            ? (cardContent as TurnCardContent).turnId
            : (cardContent as CFQCardContent).cfqId,
        currentUserId: cardContent is TurnCardContent
            ? (cardContent as TurnCardContent).currentUserId
            : (cardContent as CFQCardContent).currentUserId,
        isTurn: cardContent is TurnCardContent,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: _buildExpandedContent(context),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    if (cardContent is TurnCardContent) {
      return Consumer<ExpandedCardViewModel>(
        builder: (context, viewModel, child) {
          final turnContent = cardContent as TurnCardContent;
          return StreamBuilder<String>(
            stream: viewModel.attendingStatusStream,
            builder: (context, snapshot) {
              final attendingStatus = snapshot.data ?? 'notAnswered';
              return TurnCardContent(
                profilePictureUrl: turnContent.profilePictureUrl,
                username: turnContent.username,
                organizers: turnContent.organizers,
                turnName: turnContent.turnName,
                description: turnContent.description,
                eventDateTime: turnContent.eventDateTime,
                where: turnContent.where,
                address: turnContent.address,
                onAttendingPressed: turnContent.onAttendingPressed,
                onSharePressed: turnContent.onSharePressed,
                onSendPressed: () async {
                  final channelId = viewModel.channelId;
                  if (channelId != null && context.mounted) {
                    final isInList = await viewModel.isConversationInUserList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          eventName: turnContent.turnName,
                          channelId: channelId,
                          organizerId: turnContent.organizerId,
                          members: turnContent.organizers,
                          organizerName: turnContent.username,
                          organizerProfilePicture:
                              turnContent.profilePictureUrl,
                          currentUser: viewModel.currentUser!,
                          addConversationToUserList:
                              viewModel.addConversationToUserList,
                          removeConversationFromUserList:
                              viewModel.removeConversationFromUserList,
                          initialIsInUserConversations: isInList,
                          eventPicture: turnContent.turnImageUrl,
                          resetUnreadMessages: viewModel.resetUnreadMessages,
                        ),
                      ),
                    );
                  }
                },
                onFavoritePressed: viewModel.toggleFavorite,
                onCommentPressed: turnContent.onCommentPressed,
                turnImageUrl: turnContent.turnImageUrl,
                datePublished: turnContent.datePublished,
                moods: turnContent.moods,
                turnId: turnContent.turnId,
                organizerId: turnContent.organizerId,
                currentUserId: turnContent.currentUserId,
                favorites: turnContent.favorites,
                isFavorite: viewModel.isFavorite,
                attendingStatus: attendingStatus,
                onAttendingStatusChanged: viewModel.updateAttendingStatus,
                attendingStatusStream: viewModel.attendingStatusStream,
                attendingCountStream: viewModel.attendingCountStream,
                isExpanded: true,
                onClose: () {
                  AppLogger.debug('onClose called from ExpandedCardScreen');
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      );
    } else if (cardContent is CFQCardContent) {
      return Consumer<ExpandedCardViewModel>(
        builder: (context, viewModel, child) {
          final cfqContent = cardContent as CFQCardContent;
          return StreamBuilder<bool>(
            stream: viewModel.isFollowingUpStream,
            builder: (context, snapshot) {
              final isFollowingUp = snapshot.data ?? false;

              return CFQCardContent(
                profilePictureUrl: cfqContent.profilePictureUrl,
                username: cfqContent.username,
                organizers: cfqContent.organizers,
                moods: cfqContent.moods,
                cfqName: cfqContent.cfqName,
                description: cfqContent.description,
                datePublished: cfqContent.datePublished,
                cfqImageUrl: cfqContent.cfqImageUrl,
                location: cfqContent.location,
                when: cfqContent.when,
                followersCountStream: viewModel.followersCountStream,
                followingUp: snapshot.data != null
                    ? (isFollowingUp ? [cfqContent.currentUserId] : [])
                    : [],
                onFollowPressed: cfqContent.onFollowPressed,
                onSharePressed: cfqContent.onSharePressed,
                onSendPressed: () async {
                  final channelId = viewModel.channelId;
                  if (channelId != null && context.mounted) {
                    final isInList = await viewModel.isConversationInUserList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          eventName: cfqContent.cfqName,
                          channelId: channelId,
                          organizerId: cfqContent.organizerId,
                          members: cfqContent.organizers,
                          organizerName: cfqContent.username,
                          organizerProfilePicture: cfqContent.profilePictureUrl,
                          currentUser: viewModel.currentUser!,
                          addConversationToUserList:
                              viewModel.addConversationToUserList,
                          removeConversationFromUserList:
                              viewModel.removeConversationFromUserList,
                          initialIsInUserConversations: isInList,
                          eventPicture: cfqContent.cfqImageUrl,
                          resetUnreadMessages: viewModel.resetUnreadMessages,
                        ),
                      ),
                    );
                  }
                },
                onFavoritePressed: viewModel.toggleFavorite,
                onBellPressed: cfqContent.onBellPressed,
                cfqId: cfqContent.cfqId,
                organizerId: cfqContent.organizerId,
                currentUserId: cfqContent.currentUserId,
                favorites: cfqContent.favorites,
                isFavorite: viewModel.isFavorite,
                onFollowUpToggled: (_) => viewModel.toggleFollowUp(
                    cfqContent.cfqId, viewModel.currentUserId),
                isExpanded: true,
                onClose: () {
                  AppLogger.debug('onClose called from ExpandedCardScreen');
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      );
    } else {
      AppLogger.warning('Unsupported card content type in ExpandedCardScreen');
      return const SizedBox.shrink();
    }
  }
}
