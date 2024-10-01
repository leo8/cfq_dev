import 'package:flutter/material.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/fonts.dart';

/// A template for screens that involve a selection process.
/// It provides a customizable app bar title and a body for content.
class StandardSelectionTemplate extends StatelessWidget {
  final String title; // The title to display in the app bar
  final Widget body; // The main content of the screen

  const StandardSelectionTemplate({
    required this.title, // Title text is required for the app bar
    required this.body, // The body content of the screen
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor
          .mobileBackgroundColor, // Sets the background color for the screen
      appBar: AppBar(
        backgroundColor: CustomColor
            .mobileBackgroundColor, // Ensures app bar matches the screen's background
        centerTitle: true, // Centers the title in the app bar
        title: Text(
          title, // Displays the provided title in the app bar
          style: const TextStyle(
            fontWeight:
                CustomFont.fontWeightBold, // Bold font style for the title
            fontSize: CustomFont.fontSize20, // Font size of 20 for the title
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20.0), // Adds padding around the body content
        child: body, // Injects the provided body widget
      ),
    );
  }
}
