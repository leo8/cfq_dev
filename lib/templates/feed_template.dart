import 'package:flutter/material.dart';

/// FeedTemplate is a base template for screens that require a background image and an app bar.
/// It provides a customizable app bar, background image, and body for feed-like screens.
class FeedTemplate extends StatelessWidget {
  final PreferredSizeWidget appBar; // Custom app bar for the screen
  final Widget body; // The main content of the screen
  final String backgroundImageUrl; // Background image URL for the screen

  const FeedTemplate({
    required this.appBar,
    required this.body,
    required this.backgroundImageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Makes the body extend behind the app bar, allowing the background image to appear behind it.
      extendBodyBehindAppBar: true,
      appBar: appBar, // Injects the custom app bar
      body: Container(
        // Sets a background image for the feed
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImageUrl),
            fit: BoxFit
                .cover, // Ensures the background image covers the entire screen
          ),
        ),
        child: body, // The customizable content passed into the feed
      ),
    );
  }
}
