import 'dart:typed_data';
import 'package:cfq_dev/widgets/atoms/buttons/custom_button.dart';
import 'package:cfq_dev/widgets/molecules/event_organizer.dart';
import 'package:flutter/material.dart';
import '../atoms/image_selectors/event_image_selector.dart';
import '../../models/user.dart' as model;
import '../atoms/texts/bordered_icon_text_field.dart';
import '../../utils/styles/text_styles.dart';
import '../atoms/texts/custom_text_field.dart';
import '../../models/team.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/icons.dart';

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
  final model.User currentUser;
  final TextEditingController inviteesController;
  final VoidCallback openInviteesSelectorScreen;

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
    required this.currentUser,
    required this.inviteesController,
    required this.openInviteesSelectorScreen,
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
            readOnly: true,
            onTap: openInviteesSelectorScreen,
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
