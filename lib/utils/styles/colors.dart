import 'package:flutter/material.dart';

class CustomColor {
  //CFQ Design System
  static const customBlack = Color(0xFF111113);
  static const customWhite = Color(0xFFFBFBFB);
  static const customPurple = Color(0xFFB098E6);
  static const customCyan = Color(0xFF47FFE6);
  static const turnBackground = Color(0xFF1D1D20);
  static const cfqBackground =
      LinearGradient(begin: Alignment.bottomRight, stops: [
    0,
    1
  ], colors: [
    Color(0xFF0F0F2C),
    Color(0xFF2A185C),
  ]);

  //Theme
  static const mobileBackgroundColor = Color.fromRGBO(0, 0, 0, 1);
  static const webBackgroundColor = Color.fromRGBO(18, 18, 18, 1);
  static const mobileSearchColor = Color.fromRGBO(38, 38, 38, 1);
  static const secondaryColor = Colors.grey;

  static const turnColor = Colors.cyanAccent;
  static const offColor = Colors.purpleAccent;

  //Standard colors
  static const transparent = Colors.transparent;
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = Colors.grey;
  static const green = Colors.green;
  static const red = Colors.red;
  static const blue = Colors.blue;
  static const purple = Colors.purple;

  //Variants

  //Whites
  static const white24 = Colors.white24;
  static const white54 = Colors.white54;
  static const white70 = Colors.white70;

  //Greys
  static const grey300 = Color(0xFFE0E0E0);
  static const grey900 = Color(0xFF212121);

  //Blues
  static const blueAccent = Colors.blueAccent;

  //Purples
  static const purpleAccent = Colors.purpleAccent;
  static const deepPurpleAccent = Colors.deepPurpleAccent;
  static const personnalizedPurple = Color(0xFF7A00FF);

  //Pinks
  static const pinkAccent = Colors.pinkAccent;
}
