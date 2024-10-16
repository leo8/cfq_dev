import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/string.dart';
import '../../utils/styles/text_styles.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller; // Text editing controller for input
  final String hintText; // Hint text to display in the search bar
  final Function(String)? onChanged; // Add this line

  const CustomSearchBar({
    required this.controller, // Controller to handle text input
    this.hintText = CustomString.search, // Default hint text is 'Search'
    this.onChanged, // Add this line
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46, // Set the height to 46
      child: TextField(
        controller:
            controller, // Links the search bar with the provided controller
        onChanged: onChanged, // Add this line
        decoration: InputDecoration(
          filled: true,
          fillColor:
              CustomColor.customBlack, // Slightly transparent background color
          prefixIcon: const Icon(Icons.search,
              size: 24,
              color: CustomColor.customWhite), // Search icon on the left
          hintText: hintText, // Display hint text in the search bar
          hintStyle: CustomTextStyle.body1, // Hint text style
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Rounded borders
            borderSide: const BorderSide(
              color: CustomColor.customWhite,
              width: 0.5,
            ), // Add customWhite border of 0.5
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: CustomColor.customWhite,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: CustomColor.customWhite,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
