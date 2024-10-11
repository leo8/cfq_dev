import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // Controller to manage the text input
  final String hintText; // Hint text to display in the text field
  final bool obscureText; // Toggle to hide or show the text (for passwords)
  final Widget? suffixIcon; // Optional suffix icon, e.g., a visibility toggle
  final Widget? icon; // Optional icon widget to display inside the container
  final int maxLines; // The maximum number of lines the text field can have
  final ValueChanged<String>? onChanged; // Optional onChanged callback
  final double? height; // Optional height parameter
  final TextStyle? textStyle; // New parameter for custom text style

  const CustomTextField({
    required this.controller,
    required this.hintText,
    this.obscureText =
        false, // Defaults to false, meaning text is visible by default
    this.suffixIcon, // Optional widget for suffix icon
    this.icon, // Optional widget for icon
    this.maxLines =
        1, // Defaults to 1, making it a single-line text field by default
    this.onChanged, // Optional onChanged callback
    this.height, // Optional height parameter
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          height ?? 60.0, // Set the height if provided, else default to 60.0
      decoration: BoxDecoration(
        color: CustomColor.white
            .withOpacity(0.1), // Background color with reduced opacity
        borderRadius:
            BorderRadius.circular(15), // Rounded corners for the text field
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 12), // Padding inside the container
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              // Display the icon if provided
              (icon as Icon).icon, // Extract the IconData from the widget
              color: CustomColor.white,
              size: 24.0, // Consistent icon size
            ),
            const SizedBox(width: 10.0), // Spacing between icon and text field
          ],
          Expanded(
            child: TextField(
              controller:
                  controller, // Links the TextField to the provided controller
              obscureText:
                  obscureText, // Hides text input when true (used for password fields)
              maxLines:
                  maxLines, // Controls how many lines the text field can expand to
              style: textStyle ??
                  const TextStyle(
                      color: CustomColor.white), // Text color inside the field
              onChanged:
                  onChanged, // Calls the onChanged callback when text changes
              decoration: InputDecoration(
                hintText: hintText, // Hint text shown when the field is empty
                hintStyle: textStyle ??
                    const TextStyle(
                        color: CustomColor.white70), // Style of the hint text
                border:
                    InputBorder.none, // Removes the default underline border
                suffixIcon:
                    suffixIcon, // Displays the optional suffix icon (if provided)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
