import 'package:flutter/material.dart';
import '../utils/styles/string.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold defines the overall structure of the screen
    return const Scaffold(
      // Center aligns its child (Text) in the middle of the screen
      body: Center(
        // Display a message indicating that this is the web layout
        child: Text(CustomString.thisIsWeb),
      ),
    );
  }
}
