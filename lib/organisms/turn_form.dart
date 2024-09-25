import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cfq_dev/molecules/labeled_input_field.dart';
import 'package:cfq_dev/molecules/image_selector.dart';
import 'package:cfq_dev/molecules/date_time_picker.dart';
import 'package:cfq_dev/molecules/moods_selector.dart';
import 'package:cfq_dev/molecules/address_fields_row.dart';
import 'package:cfq_dev/utils/string.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';

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
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: CustomColor.primaryColor,
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Image Selector
                ImageSelector(
                  image: image,
                  onSelectImage: onSelectImage,
                  placeholderText: CustomString.aucuneImage,
                ),
                const SizedBox(height: 12),
                // Turn Name Field
                LabeledInputField(
                  label: CustomString.nomDuTurn,
                  controller: nameController,
                  hintText: CustomString.nomDuTurn,
                ),
                const SizedBox(height: 12),
                // Date & Moods Selectors
                Row(
                  children: [
                    Expanded(
                      child: DateTimePicker(
                        label: CustomString.ajouterUneDate,
                        onSelectDateTime: onSelectDateTime,
                        displayText: dateTimeDisplay,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MoodsSelector(
                        label: CustomString.moods,
                        onSelectMoods: onSelectMoods,
                        displayText: moodsDisplay,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Address Fields Row
                AddressFieldsRow(
                  locationController: locationController,
                  addressController: addressController,
                ),
                const SizedBox(height: 12),
                // Description Field
                LabeledInputField(
                  label: CustomString.description,
                  controller: descriptionController,
                  hintText: CustomString.racontePasTaVieDisNousJusteOuTuSors,
                  isMultiline: true,
                ),
                const SizedBox(height: 12),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    child: const Text(
                      CustomString.publier,
                      style: TextStyle(
                        color: CustomColor.primaryColor,
                        fontWeight: CustomFont.fontWeightBold,
                        fontSize: CustomFont.fontSize16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
