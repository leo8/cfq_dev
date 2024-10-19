import 'package:flutter/material.dart';

class CustomColor {
  //CFQ Design System
  static const customBlack = Color(0xFF111113);
  static const customWhite = Color(0xFFFBFBFB);
  static const customPurple = Color(0xFFB098E6);
  static const customCyan = Color(0xFF47FFE6);
  static const customDarkGrey = Color(0xFF1D1D20);

  static const turnColor = Colors.cyanAccent;
  static const offColor = Colors.purpleAccent;

  static const blueNeon = Color.fromRGBO(75, 103, 110, 1);
  static const purpleNeon = Color.fromRGBO(67, 56, 98, 1);

  // static const turnBackgroundGradient = LinearGradient(
  //     begin: Alignment.bottomLeft,
  //     stops: [0, 1],
  //     colors: [Color(0xFF1D1D20), Color(0xFF1D1D20)]);

  // static const cfqBackgroundGradient =
  //     LinearGradient(begin: Alignment.bottomRight, stops: [
  //   0,
  //   1
  // ], colors: [
  //   Color(0xFF0F0F2C),
  //   Color(0xFF2A185C),
  // ]);

  static const turnBackgroundGradient =
      LinearGradient(begin: Alignment.bottomLeft, stops: [
    0,
    0.8,
    1
  ], colors: [
    CustomColor.customBlack,
    CustomColor.customBlack,
    CustomColor.blueNeon,
  ]);

  static const cfqBackgroundGradient =
      LinearGradient(begin: Alignment.bottomLeft, stops: [
    0,
    0.5,
    1
  ], colors: [
    CustomColor.purpleNeon,
    CustomColor.customBlack,
    CustomColor.customBlack,
  ]);

  //Theme
  static const mobileBackgroundColor = Color.fromRGBO(0, 0, 0, 1);
  static const webBackgroundColor = Color.fromRGBO(18, 18, 18, 1);
  static const mobileSearchColor = Color.fromRGBO(38, 38, 38, 1);
  static const secondaryColor = Colors.grey;

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
  static const grey600 = Color(0xFF757575);
  static const grey900 = Color(0xFF212121);

  //Blues
  static const blueAccent = Colors.blueAccent;

  //Purples
  static const purpleAccent = Colors.purpleAccent;
  static const deepPurpleAccent = Colors.deepPurpleAccent;
  static const personnalizedPurple = Color(0xFF7A00FF);
  static const purpleGradient = LinearGradient(
    colors: [
      CustomColor.personnalizedPurple,
      Color(0xFF7900F4)
    ], // Gradient background
  );

  //Pinks
  static const pinkAccent = Colors.pinkAccent;
}
