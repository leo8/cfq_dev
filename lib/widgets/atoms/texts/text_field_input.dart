import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController
      textEditingController; // Controller to manage the input text
  final bool
      isPassword; // To determine if the input should obscure the text (for passwords)
  final String hintText; // Placeholder text for the input field
  final TextInputType
      textInputType; // The keyboard type to use (e.g., email, number)
  final InputDecoration?
      decoration; // Optional decoration for customizing the input field
  final TextStyle?
      style; // Optional style for customizing the text inside the field

  const TextFieldInput({
    super.key,
    required this.textEditingController, // Required controller to manage the text field's input
    this.isPassword =
        false, // Defaults to false for normal text input (not password)
    required this.hintText, // Hint text for the input field
    required this.textInputType, // The type of input (e.g., Text, Email, Number)
    this.decoration, // Optional custom decoration for the input field
    this.style, // Optional custom text style
  });

  @override
  Widget build(BuildContext context) {
    // Default input border style for the TextField
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller:
          textEditingController, // The controller for managing the input text
      decoration: decoration ??
          InputDecoration(
            hintText: hintText, // Displayed when the input is empty
            border: inputBorder, // Default border when the input is in focus
            enabledBorder: inputBorder, // Border when the input is enabled
            filled:
                true, // Whether the input field is filled with background color
            contentPadding:
                const EdgeInsets.all(8), // Padding inside the input field
          ), // Use the provided decoration, or fallback to the default
      keyboardType: textInputType, // Type of input (email, text, number)
      obscureText: isPassword, // Hide the text if it's a password field
      style: style ??
          const TextStyle(
              color: CustomColor
                  .black), // Use the provided style, or default to black text color
    );
  }
}
