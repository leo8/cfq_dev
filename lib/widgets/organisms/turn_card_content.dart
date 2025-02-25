import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../molecules/turn_header.dart';
import '../molecules/turn_details.dart';
import '../molecules/turn_buttons.dart';
import '../../utils/styles/text_styles.dart';
import '../../utils/styles/neon_background.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/atoms/avatars/clickable_avatar.dart';
import '../../screens/profile_screen.dart';
import '../../screens/expanded_card_screen.dart';
import '../../utils/logger.dart';
import '../../screens/create_turn_screen.dart';
import '../../models/turn_event_model.dart';
import '../atoms/buttons/custom_button.dart';
import 'package:provider/provider.dart';
import '../../view_models/expanded_card_view_model.dart';

class TurnCardContent extends StatelessWidget {
  final String profilePictureUrl;
  final String username;
  final List<String> organizers;
  final List<String> moods;
  final String turnName;
  final String description;
  final DateTime eventDateTime;
  final DateTime? endDateTime;
  final DateTime datePublished;
  final String turnImageUrl;
  final String where;
  final VoidCallback onAttendingPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSendPressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onFavoritePressed;
  final String turnId;
  final String organizerId;
  final String currentUserId;
  final List favorites;
  final bool isFavorite;
  final String attendingStatus;
  final Function(String) onAttendingStatusChanged;
  final Stream<String> attendingStatusStream;
  final Stream<int> attendingCountStream;
  final bool isExpanded;
  final VoidCallback? onClose;
  final VoidCallback? onEditPressed;
  final bool showEditButton;

  const TurnCardContent({
    required this.attendingStatus,
    required this.onAttendingStatusChanged,
    required this.profilePictureUrl,
    required this.username,
    required this.organizers,
    required this.turnName,
    required this.description,
    required this.eventDateTime,
    this.endDateTime,
    required this.where,
    required this.onAttendingPressed,
    required this.onSharePressed,
    required this.onSendPressed,
    required this.onFavoritePressed,
    required this.onCommentPressed,
    required this.turnImageUrl,
    required this.datePublished,
    required this.moods,
    required this.turnId,
    required this.organizerId,
    required this.currentUserId,
    required this.favorites,
    required this.isFavorite,
    required this.attendingStatusStream,
    required this.attendingCountStream,
    this.isExpanded = false,
    this.onClose,
    this.onEditPressed,
    this.showEditButton = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isExpanded
          ? null
          : () {
              AppLogger.debug(
                  'TurnCardContent tapped, navigating to expanded view for turnId: $turnId');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExpandedCardScreen(
                    cardContent: TurnCardContent(
                      profilePictureUrl: profilePictureUrl,
                      username: username,
                      datePublished: datePublished,
                      turnName: turnName.toUpperCase(),
                      moods: moods,
                      eventDateTime: eventDateTime,
                      endDateTime: endDateTime,
                      where: where,
                      description: description,
                      turnId: turnId,
                      turnImageUrl: turnImageUrl,
                      onAttendingStatusChanged: onAttendingStatusChanged,
                      onSharePressed: onSharePressed,
                      onSendPressed: onSendPressed,
                      onFavoritePressed: onFavoritePressed,
                      isFavorite: isFavorite,
                      attendingStatusStream: attendingStatusStream,
                      attendingStatus: attendingStatus,
                      attendingCountStream: attendingCountStream,
                      isExpanded: true,
                      organizers: organizers,
                      onAttendingPressed: onAttendingPressed,
                      onCommentPressed: onCommentPressed,
                      organizerId: organizerId,
                      currentUserId: currentUserId,
                      favorites: favorites,
                      onClose: () {
                        AppLogger.debug(
                            'onClose called from ExpandedCardScreen');
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              );
            },
      child: Container(
        height: isExpanded ? MediaQuery.of(context).size.height : null,
        decoration: isExpanded
            ? const BoxDecoration(
                color: CustomColor.transparent, borderRadius: BorderRadius.zero)
            : BoxDecoration(
                gradient: CustomColor.turnBackgroundGradient,
                borderRadius: BorderRadius.circular(16),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TurnHeader(
              turnImageUrl: turnImageUrl,
              eventDateTime: eventDateTime,
              isExpanded: isExpanded,
              onClose: onClose,
              turnName: turnName.toUpperCase(),
            ),
            if (isExpanded)
              Expanded(
                child: NeonBackground(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  currentUserId != organizerId
                                      ? ClickableAvatar(
                                          userId: organizerId,
                                          imageUrl: profilePictureUrl,
                                          onTap: () {
                                            // Navigate to friend's profile
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileScreen(
                                                        userId: organizerId),
                                              ),
                                            );
                                          },
                                          isActive: false, // Add isActive
                                          radius: 28,
                                        )
                                      : ClickableAvatar(
                                          userId: organizerId,
                                          imageUrl: profilePictureUrl,
                                          onTap: () {},
                                        ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${username} . ${DateTimeUtils.getTimeAgo(datePublished)}',
                                            style: CustomTextStyle.body1
                                                .copyWith(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TurnButtons(
                              onAttendingPressed: onAttendingStatusChanged,
                              onSharePressed: onSharePressed,
                              onSendPressed: onSendPressed,
                              onFavoritePressed: onFavoritePressed,
                              isFavorite: isFavorite,
                              attendingStatusStream: attendingStatusStream,
                              attendingStatus: attendingStatus,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: StreamBuilder<int>(
                            stream: attendingCountStream,
                            builder: (context, snapshot) {
                              final attendingCount = snapshot.data ?? 0;
                              return TurnDetails(
                                  profilePictureUrl: profilePictureUrl,
                                  username: username,
                                  datePublished: datePublished,
                                  turnName: turnName.toUpperCase(),
                                  moods: moods,
                                  eventDateTime: eventDateTime,
                                  endDateTime: endDateTime,
                                  attendeesCount: attendingCount,
                                  where: where,
                                  description: description,
                                  turnId: turnId,
                                  isExpanded: isExpanded);
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                        if (showEditButton && onEditPressed != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ElevatedButton(
                              onPressed: onEditPressed,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit Turn'),
                                ],
                              ),
                            ),
                          ),
                        if (currentUserId == organizerId && isExpanded)
                          Column(
                            children: [
                              const SizedBox(height: 50),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: CustomButton(
                                  label: 'Modifier',
                                  color: CustomColor.customBlack,
                                  textStyle: CustomTextStyle.subButton
                                      .copyWith(color: CustomColor.customWhite),
                                  borderWidth: 0.5,
                                  borderColor: CustomColor.customWhite,
                                  onTap: () async {
                                    final wasUpdated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateTurnScreen(
                                          isEditing: true,
                                          turnToEdit: Turn(
                                            name: turnName,
                                            description: description,
                                            moods: moods,
                                            uid: organizerId,
                                            username: username,
                                            eventId: turnId,
                                            datePublished: datePublished,
                                            eventDateTime: eventDateTime,
                                            imageUrl: turnImageUrl,
                                            profilePictureUrl:
                                                profilePictureUrl,
                                            where: where,
                                            organizers: organizers,
                                            invitees: [], // We'll fetch this in the view model
                                            teamInvitees: [], // We'll fetch this in the view model
                                            channelId:
                                                '', // We'll fetch this in the view model
                                          ),
                                        ),
                                      ),
                                    );
                                    if (wasUpdated == true) {
                                      onClose?.call();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: CustomButton(
                                  label: 'Supprimer',
                                  color: CustomColor.customBlack,
                                  textStyle: CustomTextStyle.subButton.copyWith(
                                      color: CustomColor.customWhite,
                                      decoration: TextDecoration.underline),
                                  onTap: () async {
                                    bool? confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor:
                                              CustomColor.customDarkGrey,
                                          title: Text(
                                            'Es-tu sûr de vouloir supprimer ce turn ?',
                                            style: CustomTextStyle.body1,
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Text(
                                            'Cette action est irréversible.',
                                            style: CustomTextStyle.body2,
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: [
                                            TextButton(
                                                child: const Text('Annuler'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }),
                                            TextButton(
                                              child: Text(
                                                'Supprimer',
                                                style: CustomTextStyle.body2
                                                    .copyWith(
                                                  color:
                                                      CustomColor.customWhite,
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      await Provider.of<ExpandedCardViewModel>(
                                              context,
                                              listen: false)
                                          .deleteTurn();
                                      onClose?.call();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              currentUserId != organizerId
                                  ? ClickableAvatar(
                                      userId: organizerId,
                                      imageUrl: profilePictureUrl,
                                      onTap: () {
                                        // Navigate to friend's profile
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfileScreen(
                                                userId: organizerId),
                                          ),
                                        );
                                      },
                                      isActive: false, // Add isActive
                                      radius: 28,
                                    )
                                  : ClickableAvatar(
                                      userId: organizerId,
                                      imageUrl: profilePictureUrl,
                                      onTap: () {},
                                      radius: 28,
                                    ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${username} . ${DateTimeUtils.getTimeAgo(datePublished)}',
                                      style: CustomTextStyle.body1
                                          .copyWith(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TurnButtons(
                          onAttendingPressed: onAttendingStatusChanged,
                          onSharePressed: onSharePressed,
                          onSendPressed: onSendPressed,
                          onFavoritePressed: onFavoritePressed,
                          isFavorite: isFavorite,
                          attendingStatusStream: attendingStatusStream,
                          attendingStatus: attendingStatus,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: StreamBuilder<int>(
                        stream: attendingCountStream,
                        builder: (context, snapshot) {
                          final attendingCount = snapshot.data ?? 0;
                          return TurnDetails(
                            profilePictureUrl: profilePictureUrl,
                            username: username,
                            datePublished: datePublished,
                            turnName: turnName.toUpperCase(),
                            moods: moods,
                            eventDateTime: eventDateTime,
                            endDateTime: endDateTime,
                            attendeesCount: attendingCount,
                            where: where,
                            description: description,
                            turnId: turnId,
                            isExpanded: isExpanded,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
