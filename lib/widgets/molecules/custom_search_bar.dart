import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/string.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomSearchBar({
    required this.controller,
    this.hintText = CustomString.search,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: CustomColor.white24,
        prefixIcon: const Icon(CustomIcon.search, color: CustomColor.white70),
        hintText: hintText,
        hintStyle: const TextStyle(color: CustomColor.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
