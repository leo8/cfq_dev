import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // Controller to manage the text input
  final String hintText; // Hint text to display in the text field
  final bool obscureText; // Toggle to hide or show the text (for passwords)
  final Widget? suffixIcon; // Optional suffix icon, e.g., a visibility toggle
  final int maxLines; // The maximum number of lines the text field can have

  const CustomTextField({
    required this.controller,
    required this.hintText,
    this.obscureText =
        false, // Defaults to false, meaning text is visible by default
    this.suffixIcon, // Optional widget for suffix icon
    this.maxLines =
        1, // Defaults to 1, making it a single-line text field by default
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.white
            .withOpacity(0.1), // Background color with reduced opacity
        borderRadius:
            BorderRadius.circular(15), // Rounded corners for the text field
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 12), // Padding inside the container
      child: TextField(
        controller:
            controller, // Links the TextField to the provided controller
        obscureText:
            obscureText, // Hides text input when true (used for password fields)
        maxLines:
            maxLines, // Controls how many lines the text field can expand to
        style: const TextStyle(
            color: CustomColor.white), // Text color inside the field
        decoration: InputDecoration(
          hintText: hintText, // Hint text shown when the field is empty
          hintStyle: const TextStyle(
              color: CustomColor.white70), // Style of the hint text
          border: InputBorder.none, // Removes the default underline border
          suffixIcon:
              suffixIcon, // Displays the optional suffix icon (if provided)
        ),
      ),
    );
  }
}
