import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../atoms/texts/custom_text_field.dart';
import '../molecules/invitees_field.dart';
import '../../utils/styles/colors.dart';
import '../../models/user.dart' as model;

class TurnForm extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onSelectImage;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController addressController;
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

  const TurnForm({
    required this.image,
    required this.onSelectImage,
    required this.nameController,
    required this.descriptionController,
    required this.locationController,
    required this.addressController,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Image Selector
          GestureDetector(
            onTap: onSelectImage,
            child: image != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(image!),
                  )
                : const CircleAvatar(
                    radius: 50,
                    backgroundColor: CustomColor.white,
                    child: Icon(Icons.add_a_photo, color: CustomColor.white),
                  ),
          ),
          const SizedBox(height: 20),
          // Name Field
          CustomTextField(
            controller: nameController,
            hintText: 'Enter TURN name',
          ),
          const SizedBox(height: 20),
          // Description Field
          CustomTextField(
            controller: descriptionController,
            hintText: 'Enter TURN description',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          // Location Field
          CustomTextField(
            controller: locationController,
            hintText: 'Enter location',
          ),
          const SizedBox(height: 20),
          // Address Field
          CustomTextField(
            controller: addressController,
            hintText: 'Enter address',
          ),
          const SizedBox(height: 20),
          // Date and Time Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date & Time: $dateTimeDisplay',
                style: const TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: onSelectDateTime,
                child: const Text('Select'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Moods Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moods: $moodsDisplay',
                style: const TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: onSelectMoods,
                child: const Text('Select'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Invitees Field
          InviteesField(
            searchController: inviteeSearchController,
            selectedInvitees: selectedInvitees,
            searchResults: searchResults,
            isSearching: isSearching,
            onAddInvitee: onAddInvitee,
            onRemoveInvitee: onRemoveInvitee,
          ),
          const SizedBox(height: 20),
          // Submit Button
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const CircularProgressIndicator(
                    color: CustomColor.white,
                  )
                : const Text('Create TURN'),
          ),
        ],
      ),
    );
  }
}
