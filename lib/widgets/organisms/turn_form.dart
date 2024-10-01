import 'dart:typed_data'; // Import for handling image data
import 'package:flutter/material.dart'; // Import for Flutter material components
import 'package:cfq_dev/widgets/molecules/date_time_picker.dart'; // Import date time picker widget
import 'package:cfq_dev/widgets/molecules/moods_selector.dart'; // Import moods selector widget

import '../../utils/styles/colors.dart'; // Import color styles
import '../../utils/styles/fonts.dart'; // Import font styles
import '../../utils/styles/string.dart'; // Import string constants
import '../molecules/address_fields_row.dart'; // Import address fields row widget
import '../molecules/image_selector.dart'; // Import image selector widget
import '../molecules/labeled_input_field.dart'; // Import labeled input field widget

class TurnForm extends StatelessWidget {
  final Uint8List? image; // Selected image for the turn
  final VoidCallback onSelectImage; // Function to handle image selection
  final TextEditingController
      nameController; // Controller for the turn name input
  final TextEditingController
      descriptionController; // Controller for description input
  final TextEditingController
      locationController; // Controller for location input
  final TextEditingController addressController; // Controller for address input
  final VoidCallback onSelectDateTime; // Function to handle date selection
  final VoidCallback onSelectMoods; // Function to handle mood selection
  final String dateTimeDisplay; // Display text for the selected date and time
  final String moodsDisplay; // Display text for selected moods
  final bool isLoading; // Flag indicating loading state
  final VoidCallback onSubmit; // Function to handle form submission

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading // Show loading indicator if true
        ? const Center(
            child: CircularProgressIndicator(
              color: CustomColor.white, // Loading indicator color
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align children to the start
              children: [
                const SizedBox(height: 8),
                // Image Selector
                ImageSelector(
                  image: image, // Pass the selected image
                  onSelectImage: onSelectImage, // Function to select image
                  placeholderText: CustomString.aucuneImage, // Placeholder text
                ),
                const SizedBox(height: 12),
                // Turn Name Field
                LabeledInputField(
                  label: CustomString.nomDuTurn, // Label for turn name
                  controller: nameController, // Controller for turn name input
                  hintText:
                      CustomString.nomDuTurn, // Hint text for turn name input
                ),
                const SizedBox(height: 12),
                // Date & Moods Selectors
                Row(
                  children: [
                    Expanded(
                      child: DateTimePicker(
                        label: CustomString
                            .ajouterUneDate, // Label for date picker
                        onSelectDateTime:
                            onSelectDateTime, // Function to select date
                        displayText:
                            dateTimeDisplay, // Display text for selected date
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MoodsSelector(
                        label: CustomString.moods, // Label for moods selector
                        onSelectMoods:
                            onSelectMoods, // Function to select moods
                        displayText:
                            moodsDisplay, // Display text for selected moods
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Address Fields Row
                AddressFieldsRow(
                  locationController:
                      locationController, // Controller for location input
                  addressController:
                      addressController, // Controller for address input
                ),
                const SizedBox(height: 12),
                // Description Field
                LabeledInputField(
                  label:
                      CustomString.description, // Label for description field
                  controller:
                      descriptionController, // Controller for description input
                  hintText: CustomString
                      .racontePasTaVieDisNousJusteOuTuSors, // Hint text for description
                  isMultiline: true, // Enable multiline input
                ),
                const SizedBox(height: 12),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: onSubmit, // Function to submit the form
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CustomColor.purple, // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners for the button
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24), // Button padding
                    ),
                    child: const Text(
                      CustomString.publier, // Text for the button
                      style: TextStyle(
                        color: CustomColor.white, // Button text color
                        fontWeight:
                            CustomFont.fontWeightBold, // Button text weight
                        fontSize: CustomFont.fontSize16, // Button text size
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
