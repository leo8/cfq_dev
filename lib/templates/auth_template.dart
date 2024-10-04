import 'package:flutter/material.dart';

/// AuthTemplate is a base structure for authentication screens
/// It displays a full-screen background image and allows placing a child widget as the body.
class AuthTemplate extends StatelessWidget {
  final Widget body; // The widget that represents the main content

  const AuthTemplate({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing the screen when the keyboard appears
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 32), // Adds horizontal padding
          width: double.infinity, // Makes the container take up full width
          child: body, // The main content of the screen passed as a child
        ),
      ),
    );
  }
}
