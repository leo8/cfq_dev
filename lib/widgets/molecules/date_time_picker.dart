import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../atoms/labels/custom_label.dart';

class DateTimePicker extends StatelessWidget {
  final String label; // Label displayed above the button
  final VoidCallback
      onSelectDateTime; // Callback to invoke when the button is pressed
  final String
      displayText; // Text to display on the button, typically the selected date

  const DateTimePicker({
    required this.label, // Text label for the DateTimePicker
    required this.onSelectDateTime, // Function to execute when selecting date/time
    required this.displayText, // The selected date or prompt text
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(text: label), // Displaying the label text
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed:
              onSelectDateTime, // Executes the date/time selection action
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColor.purple, // Button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(
                vertical: 12), // Padding for button content
            minimumSize: const Size(double.infinity, 50), // Full-width button
          ),
          child: Text(
            displayText, // The text to show on the button, like a selected date or time
            style: const TextStyle(
              fontSize: CustomFont.fontSize14, // Text size inside the button
              color: CustomColor.white, // Text color
            ),
          ),
        ),
      ],
    );
  }
}
