import 'package:flutter/material.dart';
import '../atoms/buttons/custom_icon_button.dart';
import '../atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class TeamOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const TeamOptionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomIconButton(
          icon: icon,
          onTap: onPressed,
          color: CustomColor.personnalizedPurple,
        ),
        const SizedBox(height: 5),
        CustomText(
          text: label,
          color: CustomColor.white,
          fontSize: CustomFont.fontSize12,
        ),
      ],
    );
  }
}
