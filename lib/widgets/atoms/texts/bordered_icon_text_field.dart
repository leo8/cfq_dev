import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';

class BorderedIconTextField extends StatelessWidget {
  final IconData icon;
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final int maxLines;
  final double height;
  final VoidCallback? onTap;

  const BorderedIconTextField({
    super.key,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.maxLines = 1,
    this.height = 40.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: CustomColor.white, width: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: CustomColor.white, size: 28),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: CustomColor.white.withOpacity(0.7)),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: CustomColor.white),
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
