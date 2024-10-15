import 'dart:typed_data';
import 'package:cfq_dev/widgets/atoms/buttons/custom_button.dart';
import 'package:cfq_dev/widgets/molecules/event_organizer.dart';
import 'package:flutter/material.dart';
import '../../screens/invitees_selector_screen.dart';
import '../atoms/image_selectors/event_image_selector.dart';
import '../../models/user.dart' as model;
import '../atoms/texts/bordered_icon_text_field.dart';
import '../../utils/styles/text_styles.dart';
import '../atoms/texts/custom_text_field.dart';
import '../../models/team.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../../utils/logger.dart';

class CfqForm extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onSelectImage;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController whenController;
  final VoidCallback onSelectMoods;
  final String moodsDisplay;
  final bool isLoading;
  final VoidCallback onSubmit;
  final TextEditingController inviteeSearchController;
  final List<model.User> selectedInvitees;
  final List<dynamic> searchResults;
  final bool isSearching;
  final Function(model.User) onAddInvitee;
  final Function(model.User) onRemoveInvitee;
  final model.User currentUser;
  final List<Team> userTeams;
  final List<Team> selectedTeams;
  final Function(Team) onAddTeam;
  final Function(Team) onRemoveTeam;
  final Function(String) onSearch;
  final VoidCallback onSelectEverybody;
  final bool isEverybodySelected;
  final TextEditingController inviteesController;

  const CfqForm({
    super.key,
    required this.image,
    required this.onSelectImage,
    required this.nameController,
    required this.descriptionController,
    required this.locationController,
    required this.whenController,
    required this.onSelectMoods,
    required this.moodsDisplay,
    required this.isLoading,
    required this.onSubmit,
    required this.inviteeSearchController,
    required this.selectedInvitees,
    required this.searchResults,
    required this.isSearching,
    required this.onAddInvitee,
    required this.onRemoveInvitee,
    required this.currentUser,
    required this.userTeams,
    required this.selectedTeams,
    required this.onAddTeam,
    required this.onRemoveTeam,
    required this.onSearch,
    required this.onSelectEverybody,
    required this.isEverybodySelected,
    required this.inviteesController,
  });

  String _formatInviteesText(List<model.User> invitees, List<Team> teams) {
    List<String> items = [];
    items.addAll(invitees.map((user) => user.username));
    items.addAll(teams.map((team) => team.name));
    return items.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              CustomString.cfqCapital,
              style: CustomTextStyle.hugeTitle.copyWith(fontSize: 32),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
            child:
                EventImageSelector(image: image, onSelectImage: onSelectImage),
          ),
          const SizedBox(height: 15),
          EventOrganizer(
            profilePictureUrl: currentUser.profilePictureUrl,
            username: currentUser.username,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.eventTitle,
            controller: nameController,
            hintText: CustomString.eventTitle,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.eventMood,
            controller: TextEditingController(text: moodsDisplay),
            hintText: CustomString.whatMood,
            readOnly: true,
            onTap: onSelectMoods,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.calendar,
            controller: whenController,
            hintText: CustomString.when,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.eventLocation,
            controller: locationController,
            hintText: CustomString.where,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: descriptionController,
            hintText: CustomString.describeCfq,
            maxLines: 50,
            height: 100,
          ),
          const SizedBox(height: 15),
          BorderedIconTextField(
            icon: CustomIcon.eventInvitees,
            controller: inviteesController,
            hintText: CustomString.who,
            onTap: () async {
              AppLogger.debug('Opening InviteesSelectorScreen');
              AppLogger.debug(
                  'Initial selected invitees: ${selectedInvitees.length}');
              AppLogger.debug(
                  'Initial selected teams: ${selectedTeams.length}');
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InviteesSelectorScreen(
                    initialSelectedInvitees: selectedInvitees,
                    initialSelectedTeams: selectedTeams,
                    searchResults: searchResults,
                    searchController: inviteeSearchController,
                    isSearching: isSearching,
                    onAddInvitee: onAddInvitee,
                    onRemoveInvitee: onRemoveInvitee,
                    onAddTeam: onAddTeam,
                    onRemoveTeam: onRemoveTeam,
                    onSearch: onSearch,
                    onSelectEverybody: onSelectEverybody,
                    isEverybodySelected: isEverybodySelected,
                  ),
                ),
              );
              if (result != null) {
                AppLogger.debug('Received result from InviteesSelectorScreen');
                AppLogger.debug(
                    'Returned invitees: ${result['invitees'].length}');
                AppLogger.debug('Returned teams: ${result['teams'].length}');
                // Update the selected invitees and teams
                onAddInvitee(result['invitees']);
                onAddTeam(result['teams']);
                // Update the inviteesController text based on the selection
                inviteesController.text =
                    _formatInviteesText(result['invitees'], result['teams']);
                AppLogger.debug(
                    'Updated inviteesController text: ${inviteesController.text}');
              } else {
                AppLogger.debug(
                    'No result received from InviteesSelectorScreen');
              }
            },
          ),
          const SizedBox(height: 15),
          CustomButton(
            label: CustomString.create,
            onTap: isLoading ? () {} : onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
