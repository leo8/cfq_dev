import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../molecules/invitees_field.dart';
import '../atoms/image_selectors/event_image_selector.dart';
import '../../models/user.dart' as model;
import '../atoms/texts/bordered_icon_text_field.dart';
import '../atoms/avatars/custom_avatar.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../atoms/texts/custom_text.dart';
import '../../models/team.dart';

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

  const CfqForm({
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventImageSelector(
            image: image,
            onSelectImage: onSelectImage,
            width: MediaQuery.of(context).size.width * 0.60,
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          const SizedBox(height: 8),
          BorderedIconTextField(
            icon: Icons.title,
            controller: nameController,
            hintText: 'Titre de l\'event',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: CustomColor.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt,
                          color: CustomColor.white, size: 16),
                      const SizedBox(width: 8),
                      CustomText(
                        text: 'Organisé par',
                        color: CustomColor.white,
                        fontSize: CustomFont.fontSize16,
                      ),
                      const SizedBox(width: 30),
                      CustomAvatar(
                        imageUrl: currentUser.profilePictureUrl,
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        text: currentUser.username,
                        color: CustomColor.white,
                        fontSize: CustomFont.fontSize16,
                        fontWeight: CustomFont.fontWeightBold,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BorderedIconTextField(
            icon: Icons.mood,
            controller: TextEditingController(text: moodsDisplay),
            hintText: 'Quel mood ?',
            readOnly: true,
            onTap: onSelectMoods,
          ),
          const SizedBox(height: 8),
          BorderedIconTextField(
            icon: Icons.calendar_today,
            controller: whenController,
            hintText: 'Quand ?',
          ),
          const SizedBox(height: 8),
          BorderedIconTextField(
            icon: Icons.location_on,
            controller: locationController,
            hintText: 'Où ? (un lieu, un nom, mets ce que tu veux)',
          ),
          const SizedBox(height: 8),
          BorderedIconTextField(
            icon: Icons.description,
            controller: descriptionController,
            hintText: 'Décris juste l\'event, raconte pas ta vie',
            maxLines: 50,
            height: 80,
          ),
          const SizedBox(height: 8),
          InviteesField(
            searchController: inviteeSearchController,
            selectedInvitees: selectedInvitees,
            selectedTeams: selectedTeams,
            searchResults: searchResults,
            isSearching: isSearching,
            onAddInvitee: onAddInvitee,
            onRemoveInvitee: onRemoveInvitee,
            onAddTeam: onAddTeam,
            onRemoveTeam: onRemoveTeam,
            onSelectEverybody: onSelectEverybody,
            onSearch: onSearch,
            isEverybodySelected: isEverybodySelected,
          ),
        ],
      ),
    );
  }
}
