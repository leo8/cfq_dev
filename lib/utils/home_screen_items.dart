import 'package:flutter/material.dart';

import '../screens/add_post_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/thread_screen.dart';

// Define a list of screens associated with nav bar icons
class CustomHomeScreenItems {
  static const homeScreenItems = [
    ThreadScreen(),
    Center(child: Text('Map')),
    AddPostScreen(),
    Center(child: Text('Calendar')),
    ProfileScreen()
  ];
}
