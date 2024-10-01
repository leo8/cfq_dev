import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';
import '../atoms/labels/custom_label.dart';

class MoodsSelector extends StatelessWidget {
  final String label; // The label for the mood selector
  final VoidCallback
      onSelectMoods; // Callback function when the button is pressed
  final String
      displayText; // Text to display on the button, such as selected moods

  const MoodsSelector({
    required this.label,
    required this.onSelectMoods,
    required this.displayText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label for the moods selector
        CustomLabel(text: label),
        const SizedBox(height: 6), // Space between label and button
        // Button to select moods
        ElevatedButton(
          onPressed: onSelectMoods, // Trigger mood selection when pressed
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColor.purple, // Button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(vertical: 12), // Button padding
            minimumSize: const Size(double.infinity, 50), // Full width button
          ),
          child: Text(
            displayText, // Display selected moods or default text
            style: const TextStyle(fontSize: CustomFont.fontSize14),
            textAlign: TextAlign.center, // Center the text
          ),
        ),
      ],
    );
  }
}
