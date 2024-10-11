import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class CustomTextStyle {
  // CFQ Theme
  static TextStyle hugeTitle = GoogleFonts.oswald(
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

  static TextStyle title1 = GoogleFonts.robotoCondensed(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: CustomColor.customWhite,
  );

  static TextStyle title2 = GoogleFonts.robotoCondensed(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: CustomColor.customWhite,
  );

  static TextStyle title3 = GoogleFonts.robotoCondensed(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: CustomColor.customWhite,
  );

  static TextStyle body1 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle body2 = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle miniBody = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle xsBody = GoogleFonts.roboto(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle subButton = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  static TextStyle miniButton = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: CustomColor.customWhite,
  );

  //Colored text styles

  static TextStyle redtitle3 = GoogleFonts.robotoCondensed(
    color: CustomColor.red,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle pinkAccentMiniBody = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: CustomColor.pinkAccent,
  );

  static TextStyle personnalizedPurpleTitle1 = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: CustomColor.personnalizedPurple,
  );
}
