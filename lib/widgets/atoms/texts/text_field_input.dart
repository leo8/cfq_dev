import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPassword;
  final String hintText;
  final TextInputType textInputType;
  final InputDecoration? decoration; // Optional decoration parameter
  final TextStyle? style; // Optional text style parameter

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPassword = false,
    required this.hintText,
    required this.textInputType,
    this.decoration, // Accepting optional decoration
    this.style, // Accepting optional style
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller: textEditingController,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            border: inputBorder,
            enabledBorder: inputBorder,
            filled: true,
            contentPadding: const EdgeInsets.all(8),
          ), // Use custom decoration if provided, otherwise use default
      keyboardType: textInputType,
      obscureText: isPassword,
      style: style ??
          const TextStyle(
              color: CustomColor.black), // Use custom style if provided
    );
  }
}
