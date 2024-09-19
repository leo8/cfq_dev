import 'package:cfq_dev/screens/add_cfq_screen.dart';
import 'package:cfq_dev/screens/add_post_screen.dart';
import 'package:cfq_dev/screens/add_turn_screen.dart';
import 'package:flutter/material.dart';

const webScreenSize = 600;
const homeScreenItems = [
  Center(child: Text('Feed')),
  Center(child: Text('Map')),
  AddPostScreen(),
  Center(child: Text('Calendar')),
  Center(child: Text('Profile')),
];
