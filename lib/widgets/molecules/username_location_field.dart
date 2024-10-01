import 'package:flutter/material.dart';
import '../../utils/styles/string.dart';
import '../atoms/texts/custom_text_field.dart';

class UsernameLocationFields extends StatelessWidget {
  final TextEditingController
      usernameController; // Controller for the username input
  final TextEditingController
      locationController; // Controller for the location input

  const UsernameLocationFields({
    super.key,
    required this.usernameController, // Requires a username controller
    required this.locationController, // Requires a location controller
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: usernameController, // Username input field
            hintText: CustomString.unPetitNom, // Placeholder text
          ),
        ),
        const SizedBox(width: 10), // Space between the two text fields
        Expanded(
          child: CustomTextField(
            controller: locationController, // Location input field
            hintText: CustomString.taLocalisation, // Placeholder text
          ),
        ),
      ],
    );
  }
}
