import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class CustomTextStyle {
  // CFQ Theme
  static TextStyle hugeTitle = const TextStyle(
    fontFamily: 'GigalypseTrialRegular',
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: CustomColor.customWhite,
  );

  static TextStyle hugeTitle2 = GoogleFonts.anton(
    fontSize: 36,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.2,
    color: CustomColor.customWhite,
  );

  static TextStyle title1 = const TextStyle(
    fontFamily: 'GigalypseTrialRegular',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: CustomColor.customWhite,
  );

  static TextStyle title2 = const TextStyle(
    fontFamily: 'GigalypseTrialRegular',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: CustomColor.customWhite,
  );

  static TextStyle title3 = const TextStyle(
    fontFamily: 'GigalypseTrialRegular',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: CustomColor.customWhite,
  );

  static TextStyle body1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle body2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle miniBody = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle xsBody = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle subButton = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: CustomColor.customWhite,
  );

  static TextStyle miniButton = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  //Methods
  static TextStyle getColoredTextStyle(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }
}
