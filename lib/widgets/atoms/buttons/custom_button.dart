import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';
import '../../../utils/styles/fonts.dart';

class CustomButton extends StatelessWidget {
  final String label; // The button label text
  final VoidCallback
      onTap; // Function to be triggered when the button is tapped
  final bool isLoading; // Indicates if the button is in a loading state

  // Constructor for the custom button
  const CustomButton({
    super.key,
    required this.label, // Button label is required
    required this.onTap, // onTap callback is required
    this.isLoading = false, // Default value for isLoading is false
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap, // Disable tap if the button is loading
      child: isLoading
          ? const Center(
              // Show a loading spinner if isLoading is true
              child: CircularProgressIndicator(
                color: CustomColor.white, // White loading spinner color
              ),
            )
          : Container(
              width:
                  double.infinity, // Button width takes up the full container
              alignment: Alignment.center, // Centers the button label
              padding: const EdgeInsets.symmetric(
                  vertical: 16), // Padding for the button
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                gradient: const LinearGradient(
                  colors: [
                    CustomColor.personnalizedPurple,
                    Color(0xFF7900F4)
                  ], // Gradient background
                ),
              ),
              child: Text(
                label, // Button text
                style: const TextStyle(
                  color: CustomColor.white, // Text color is white
                  fontWeight: CustomFont.fontWeightBold, // Bold font
                  fontSize: CustomFont.fontSize18, // Font size
                ),
              ),
            ),
    );
  }
}
