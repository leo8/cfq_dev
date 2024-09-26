import 'package:flutter/material.dart';

import '../utils/gen/colors.dart';
import '../utils/gen/fonts.dart';

class StandardSelectionTemplate extends StatelessWidget {
  final String title;
  final Widget body;

  const StandardSelectionTemplate({
    required this.title,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: CustomColor.mobileBackgroundColor,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: CustomFont.fontWeightBold,
            fontSize: CustomFont.fontSize20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: body,
      ),
    );
  }
}
