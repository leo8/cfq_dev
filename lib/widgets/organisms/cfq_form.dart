import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/molecules/date_time_picker.dart';
import 'package:cfq_dev/widgets/molecules/moods_selector.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../../utils/styles/string.dart';
import '../molecules/image_selector.dart';
import '../molecules/labeled_input_field.dart';

class CFQForm extends StatelessWidget {
  final Uint8List? image; // Selected image for the CFQ
  final VoidCallback onSelectImage; // Callback for image selection
  final TextEditingController nameController; // Controller for CFQ name input
  final TextEditingController
      descriptionController; // Controller for description input
  final TextEditingController
      locationController; // Controller for location input
  final VoidCallback onSelectDateTime; // Callback for selecting date and time
  final VoidCallback onSelectMoods; // Callback for selecting moods
  final String dateTimeDisplay; // Text to display selected date and time
  final String moodsDisplay; // Text to display selected moods
  final bool isLoading; // Flag to indicate loading state
  final VoidCallback onSubmit; // Callback for form submission

  const CFQForm({
    required this.image,
    required this.onSelectImage,
    required this.nameController,
    required this.descriptionController,
    required this.locationController,
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
    // Show a loading indicator if the form is loading
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: CustomColor.white,
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
                  image: image,
                  onSelectImage: onSelectImage,
                  placeholderText: CustomString
                      .aucuneImage, // Placeholder text when no image is selected
                ),
                const SizedBox(height: 12),
                // CFQ Name Input Field
                LabeledInputField(
                  label: CustomString.nomDuCfq, // Label for the CFQ name field
                  controller: nameController, // Controller for CFQ name input
                  hintText:
                      CustomString.nomDuCfq, // Hint text for CFQ name field
                ),
                const SizedBox(height: 12),
                // Date and Moods Selectors
                Row(
                  children: [
                    Expanded(
                      child: DateTimePicker(
                        label: CustomString
                            .ajouterUneDate, // Label for date picker
                        onSelectDateTime:
                            onSelectDateTime, // Callback for date selection
                        displayText:
                            dateTimeDisplay, // Text to display selected date
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MoodsSelector(
                        label: CustomString.moods, // Label for moods selector
                        onSelectMoods:
                            onSelectMoods, // Callback for mood selection
                        displayText:
                            moodsDisplay, // Text to display selected moods
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Location Input Field
                LabeledInputField(
                  label: CustomString.ou, // Label for the location field
                  controller:
                      locationController, // Controller for location input
                  hintText: CustomString.ou, // Hint text for location field
                ),
                const SizedBox(height: 12),
                // Description Input Field
                LabeledInputField(
                  label: CustomString
                      .description, // Label for the description field
                  controller:
                      descriptionController, // Controller for description input
                  hintText: CustomString
                      .racontePasTaVieDisNousJusteOuTuSors, // Hint text for description field
                  isMultiline:
                      true, // Allows multiple lines for the description
                ),
                const SizedBox(height: 12),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: onSubmit, // Callback for form submission
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CustomColor.purple, // Background color for the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24), // Padding inside the button
                    ),
                    child: const Text(
                      CustomString.publier, // Text on the button
                      style: TextStyle(
                        color: CustomColor.white, // Text color
                        fontWeight: CustomFont.fontWeightBold, // Text weight
                        fontSize: CustomFont.fontSize16, // Text size
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
