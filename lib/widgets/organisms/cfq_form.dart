import 'dart:typed_data';
import 'package:cfq_dev/widgets/molecules/icon_date_time_selector.dart';
import 'package:cfq_dev/widgets/molecules/icon_moods_selector.dart';
import 'package:flutter/material.dart';
import '../molecules/custom_icon_text_field.dart';
import '../molecules/invitees_field.dart';
import '../atoms/image_selectors/event_image_selector.dart';
import '../../models/user.dart' as model;

class CfqForm extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onSelectImage;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController whenController;
  final VoidCallback onSelectDateTime;
  final VoidCallback onSelectMoods;
  final String dateTimeDisplay;
  final String moodsDisplay;
  final bool isLoading;
  final VoidCallback onSubmit;
  final TextEditingController inviteeSearchController;
  final List<model.User> selectedInvitees;
  final List<model.User> searchResults;
  final bool isSearching;
  final Function(model.User) onAddInvitee;
  final Function(model.User) onRemoveInvitee;

  const CfqForm({
    required this.image,
    required this.onSelectImage,
    required this.nameController,
    required this.descriptionController,
    required this.locationController,
    required this.whenController,
    required this.onSelectDateTime,
    required this.onSelectMoods,
    required this.dateTimeDisplay,
    required this.moodsDisplay,
    required this.isLoading,
    required this.onSubmit,
    required this.inviteeSearchController,
    required this.selectedInvitees,
    required this.searchResults,
    required this.isSearching,
    required this.onAddInvitee,
    required this.onRemoveInvitee,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Event Image Selector
        EventImageSelector(
          image: image,
          onSelectImage: onSelectImage,
          width: 300, // Full width
          height: 120, // Adjust height as needed
        ),
        const SizedBox(height: 20),

        // Name Field with Icon (e.g., person icon)
        CustomIconTextField(
          icon: Icons.person,
          controller: nameController,
          hintText: 'Enter TURN name',
          height: 35.0,
        ),
        const SizedBox(height: 10),

        // Description Field with Icon (e.g., description icon)
        CustomIconTextField(
          icon: Icons.description,
          controller: descriptionController,
          hintText: 'Enter TURN description',
          maxLines: 3,
          height: 120.0,
        ),
        const SizedBox(height: 10),

        // Location Field with Icon (e.g., location_on icon)
        CustomIconTextField(
          icon: Icons.location_on,
          controller: locationController,
          hintText: 'Enter location',
          height: 35.0,
        ),
        const SizedBox(height: 10),

        // Address Field with Icon (e.g., home icon)
        CustomIconTextField(
          icon: Icons.home,
          controller: whenController,
          hintText: 'Quand ?',
          height: 35.0,
        ),
        const SizedBox(height: 10),

        // Moods Selector Molecule
        IconMoodsSelector(
          moodsText: moodsDisplay,
          onTap: onSelectMoods,
          height: 35.0,
        ),
        const SizedBox(height: 10),

        // Invitees Field
        InviteesField(
          searchController: inviteeSearchController,
          selectedInvitees: selectedInvitees,
          searchResults: searchResults,
          isSearching: isSearching,
          onAddInvitee: onAddInvitee,
          onRemoveInvitee: onRemoveInvitee,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
