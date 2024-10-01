import 'package:flutter/material.dart';

import '../../utils/styles/string.dart';
import '../atoms/texts/custom_text_field.dart';

class AddressFieldsRow extends StatelessWidget {
  final TextEditingController
      locationController; // Controller for the "Location" input field
  final TextEditingController
      addressController; // Controller for the "Address" input field

  const AddressFieldsRow({
    required this.locationController,
    required this.addressController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // First expanded widget for the location field
        Expanded(
          child: CustomTextField(
            controller: locationController,
            hintText: CustomString.ou, // Hint text: "Where" (in French: "Où")
          ),
        ),
        const SizedBox(width: 8), // Spacing between the two fields
        // Second expanded widget for the address field
        Expanded(
          child: CustomTextField(
            controller: addressController,
            hintText: CustomString.adresse, // Hint text: "Address"
          ),
        ),
      ],
    );
  }
}
