import 'package:cfq_dev/screens/add_cfq_screen.dart';
import 'package:cfq_dev/screens/add_post_screen.dart';
import 'package:cfq_dev/screens/add_turn_screen.dart';
import 'package:cfq_dev/screens/profile_screen.dart';
import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:flutter/material.dart';

const webScreenSize = 600;
const homeScreenItems = [
  ThreadScreen(),
  Center(child: Text('Map')),
  AddPostScreen(),
  Center(child: Text('Calendar')),
  ProfileScreen()
];

const List<String> availableMoods = [
  'maison',
  'bar',
  'club',
  'street',
  'turn',
  'chill'
];