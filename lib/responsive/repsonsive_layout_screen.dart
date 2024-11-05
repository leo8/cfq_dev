import 'package:cfq_dev/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/styles/dimensions.dart';

class RepsonsiveLayout extends StatefulWidget {
  final Widget webScreenLayout; // Web layout widget for larger screens
  final Widget mobileScreenLayout; // Mobile layout widget for smaller screens

  const RepsonsiveLayout({
    super.key,
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  State<RepsonsiveLayout> createState() => _RepsonsiveLayoutState();
}

class _RepsonsiveLayoutState extends State<RepsonsiveLayout> {
  @override
  void initState() {
    super.initState();
    addData(); // Initialize and fetch user data when the layout is built
  }

  // Method to refresh and load user data using the UserProvider
  addData() async {
    // Fetch the UserProvider instance without rebuilding the widget
    UserProvider userProvider = Provider.of(context, listen: false);
    // Asynchronously refresh the current user's data
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine the screen size and layout accordingly
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen width is greater than the web screen size, show the web layout
        if (constraints.maxWidth > CustomDimension.webScreenSize) {
          return widget.webScreenLayout;
        }
        // Otherwise, show the mobile layout
        return widget.mobileScreenLayout;
      },
    );
  }
}
