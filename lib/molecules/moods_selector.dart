import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/labels/custom_label.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';

class MoodsSelector extends StatelessWidget {
  final String label;
  final VoidCallback onSelectMoods;
  final String displayText;

  const MoodsSelector({
    required this.label,
    required this.onSelectMoods,
    required this.displayText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomLabel(text: label),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: onSelectMoods,
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
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
