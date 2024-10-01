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
          decoration: const BoxDecoration(
            // Background image for the authentication screen
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1617957689233-207e3cd3c610?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ),
              fit: BoxFit
                  .cover, // Ensures the image covers the whole screen area
            ),
          ),
          child: body, // The main content of the screen passed as a child
        ),
      ),
    );
  }
}
