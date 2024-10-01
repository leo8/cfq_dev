import 'package:flutter/material.dart';

import '../screens/add_post_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/thread_screen.dart';

class CustomHomeScreenItems {
  static const homeScreenItems = [
    ThreadScreen(),
    Center(child: Text('Map')),
    AddPostScreen(),
    Center(child: Text('Calendar')),
    ProfileScreen()
  ];
}
