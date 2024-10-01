import 'package:flutter/material.dart';

/// ProfileTemplate is a template for profile screens that include a background image
/// and a customizable body section. This is useful for creating consistent profile UI designs.
class ProfileTemplate extends StatelessWidget {
  final Widget body; // The main content of the profile screen
  final String backgroundImageUrl; // Background image URL for the profile

  const ProfileTemplate({
    required this.body, // The body widget is required and will be passed in by the screen using this template
    required this.backgroundImageUrl, // The background image URL is required to set the profile's background
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Ensures content is placed within safe areas of the screen (e.g., avoids notches)
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 32), // Adds horizontal padding for the content
        width: double
            .infinity, // Makes the container fill the full width of the screen
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                backgroundImageUrl), // Loads the background image from the provided URL
            fit: BoxFit
                .cover, // Ensures the background image covers the entire container
          ),
        ),
        child: body, // Injects the custom content passed as the profile's body
      ),
    );
  }
}
