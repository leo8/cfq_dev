import 'package:flutter/material.dart';
import '../widgets/organisms/turn_card_content.dart';
import '../widgets/organisms/cfq_card_content.dart';
import '../utils/logger.dart';

class ExpandedCardScreen extends StatelessWidget {
  final Widget cardContent;

  const ExpandedCardScreen({Key? key, required this.cardContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building ExpandedCardScreen');
    return Scaffold(
      body: SingleChildScrollView(
        child: _buildExpandedContent(context),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    if (cardContent is TurnCardContent) {
      final turnContent = cardContent as TurnCardContent;
      return TurnCardContent(
        profilePictureUrl: turnContent.profilePictureUrl,
        username: turnContent.username,
        organizers: turnContent.organizers,
        turnName: turnContent.turnName,
        description: turnContent.description,
        eventDateTime: turnContent.eventDateTime,
        where: turnContent.where,
        address: turnContent.address,
        attendeesCount: turnContent.attendeesCount,
        onAttendingPressed: turnContent.onAttendingPressed,
        onSharePressed: turnContent.onSharePressed,
        onSendPressed: turnContent.onSendPressed,
        onFavoritePressed: turnContent.onFavoritePressed,
        onCommentPressed: turnContent.onCommentPressed,
        turnImageUrl: turnContent.turnImageUrl,
        datePublished: turnContent.datePublished,
        moods: turnContent.moods,
        turnId: turnContent.turnId,
        organizerId: turnContent.organizerId,
        currentUserId: turnContent.currentUserId,
        favorites: turnContent.favorites,
        isFavorite: turnContent.isFavorite,
        attendingStatus: turnContent.attendingStatus,
        onAttendingStatusChanged: turnContent.onAttendingStatusChanged,
        attendingStatusStream: turnContent.attendingStatusStream,
        attendingCountStream: turnContent.attendingCountStream,
        isExpanded: true,
        onClose: () {
          AppLogger.debug('onClose called from ExpandedCardScreen');
          Navigator.of(context).pop();
        },
      );
    } else if (cardContent is CFQCardContent) {
      final cfqContent = cardContent as CFQCardContent;
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
        followingUp: cfqContent.followingUp,
        onFollowPressed: cfqContent.onFollowPressed,
        onSharePressed: cfqContent.onSharePressed,
        onSendPressed: cfqContent.onSendPressed,
        onFavoritePressed: cfqContent.onFavoritePressed,
        onBellPressed: cfqContent.onBellPressed,
        cfqId: cfqContent.cfqId,
        organizerId: cfqContent.organizerId,
        currentUserId: cfqContent.currentUserId,
        favorites: cfqContent.favorites,
        isFavorite: cfqContent.isFavorite,
        onFollowUpToggled: cfqContent.onFollowUpToggled,
        isExpanded: true,
        onClose: () {
          AppLogger.debug('onClose called from ExpandedCardScreen');
          Navigator.of(context).pop();
        },
        //onClose: onClose,
      );
    } else {
      AppLogger.warning('Unsupported card content type in ExpandedCardScreen');
      return const SizedBox.shrink();
    }
  }
}
