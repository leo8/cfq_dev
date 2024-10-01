import 'package:flutter/material.dart';
import '../atoms/labels/custom_label.dart';
import '../atoms/texts/custom_text_field.dart';

class LabeledInputField extends StatelessWidget {
  final String label; // The label for the input field
  final TextEditingController controller; // Controller for handling input text
  final String hintText; // Hint text for the input field
  final bool isMultiline; // If true, allows multi-line input

  const LabeledInputField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.isMultiline = false, // Defaults to single-line input
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align label and field to the start
      children: [
        // Label for the input field
        CustomLabel(text: label),
        const SizedBox(height: 6), // Small space between label and input field
        // Text field with single or multi-line input capability
        CustomTextField(
          controller: controller, // Bind controller to the text field
          hintText: hintText, // Display hint text in the field
          maxLines:
              isMultiline ? 5 : 1, // Multi-line if true, otherwise single line
        ),
      ],
    );
  }
}
