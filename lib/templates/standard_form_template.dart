import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';

/// A standard template for form screens, providing a customizable app bar
/// and body layout. This ensures consistency across different forms in the app.
class StandardFormTemplate extends StatelessWidget {
  final Widget appBarTitle; // The title widget for the app bar
  final List<Widget>
      appBarActions; // A list of widgets for the app bar's action buttons
  final Widget body; // The main content of the form screen
  final VoidCallback
      onBackPressed; // Callback for handling the back button press

  const StandardFormTemplate({
    required this.appBarTitle, // The app bar title widget is required for proper customization
    required this.appBarActions, // A list of action buttons for the app bar
    required this.body, // The form's body content
    required this.onBackPressed, // The back button callback for navigation control
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CustomColor.mobileBackgroundColor, // Sets the background color
      appBar: AppBar(
        backgroundColor: CustomColor
            .mobileBackgroundColor, // App bar background matches screen background
        centerTitle: true, // Centers the app bar title
        title: appBarTitle, // Custom app bar title passed in
        leading: IconButton(
          icon: const Icon(CustomIcon.close), // Close icon for back navigation
          onPressed: onBackPressed, // Calls the provided back button callback
        ),
        actions: appBarActions, // Adds the action buttons to the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20), // Adds padding to the sides of the form
        child: body, // Injects the form's main content
      ),
    );
  }
}
