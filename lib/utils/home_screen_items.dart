import 'package:cfq_dev/pages/add_post_screen.dart';
import 'package:cfq_dev/pages/profile_screen.dart';
import 'package:cfq_dev/pages/thread_screen.dart';
import 'package:flutter/material.dart';

class CustomHomeScreenItems {
  static const homeScreenItems = [
    ThreadScreen(),
    Center(child: Text('Map')),
    AddPostScreen(),
    Center(child: Text('Calendar')),
    ProfileScreen()
  ];
}
