import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/string.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller; // Text editing controller for input
  final String hintText; // Hint text to display in the search bar

  const CustomSearchBar({
    required this.controller, // Controller to handle text input
    this.hintText = CustomString.search, // Default hint text is 'Search'
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:
          controller, // Links the search bar with the provided controller
      decoration: InputDecoration(
        filled: true,
        fillColor: CustomColor.white24, // Slightly transparent background color
        prefixIcon: const Icon(
          CustomIcon.search, // Search icon on the left
          color: CustomColor.white70,
        ),
        hintText: hintText, // Display hint text in the search bar
        hintStyle:
            const TextStyle(color: CustomColor.white70), // Hint text style
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded borders
          borderSide: BorderSide.none, // No visible border
        ),
      ),
    );
  }
}
