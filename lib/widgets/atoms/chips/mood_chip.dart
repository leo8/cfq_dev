import 'package:flutter/material.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/text_styles.dart';
import '../../../utils/styles/colors.dart';

class MoodChip extends StatelessWidget {
  final CustomIcon icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CustomColor.customWhite.withOpacity(0.2)
              : CustomColor.customBlack.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CustomColor.customWhite.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon.copyWith(color: CustomColor.customWhite, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: CustomTextStyle.body2,
            ),
          ],
        ),
      ),
    );
  }
}
