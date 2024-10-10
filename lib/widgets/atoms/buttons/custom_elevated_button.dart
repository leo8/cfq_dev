import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback
      onPressed; // Function to be triggered when the button is pressed
  final Widget
      child; // The child widget (typically a text or icon) inside the button
  final Color? backgroundColor; // Optional background color for the button
  final OutlinedBorder?
      shape; // Optional shape for the button (e.g., rounded corners)

  const CustomElevatedButton({
    required this.onPressed, // onPressed callback is required
    required this.child, // Child widget is required (usually a Text widget)
    this.backgroundColor, // Optional background color
    this.shape, // Optional shape for the button
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Define the onPressed function
      style: ElevatedButton.styleFrom(
        // Set the background color if provided
        backgroundColor: backgroundColor,
        // Set the shape if provided
        shape: shape,
      ),
      child: child, // Button content (text, icon, or any widget)
    );
  }
}
