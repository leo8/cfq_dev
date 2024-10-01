import 'package:flutter/material.dart';

import '../atoms/labels/custom_label.dart';
import '../atoms/texts/custom_text_field.dart';

class LabeledInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isMultiline;

  const LabeledInputField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.isMultiline = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(text: label),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller,
          hintText: hintText,
          maxLines: isMultiline ? 5 : 1,
        ),
      ],
    );
  }
}
