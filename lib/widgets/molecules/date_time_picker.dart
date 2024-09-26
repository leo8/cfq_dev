import 'package:flutter/material.dart';
import '../../gen/colors.dart';
import '../../gen/fonts.dart';
import '../atoms/labels/custom_label.dart';

class DateTimePicker extends StatelessWidget {
  final String label;
  final VoidCallback onSelectDateTime;
  final String displayText;

  const DateTimePicker({
    required this.label,
    required this.onSelectDateTime,
    required this.displayText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomLabel(text: label),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: onSelectDateTime,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColor.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            displayText,
            style: const TextStyle(fontSize: CustomFont.fontSize14),
          ),
        ),
      ],
    );
  }
}
