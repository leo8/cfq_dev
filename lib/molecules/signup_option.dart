import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/string.dart';

class SignUpOption extends StatelessWidget {
  final VoidCallback onTap;

  const SignUpOption({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          CustomString.tAsPasEncoreDeCompte,
          style: TextStyle(color: CustomColor.white70),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            CustomString.jemInscris,
            style: TextStyle(
              color: CustomColor.personnalizedPurple,
              fontWeight: CustomFont.fontWeightBold,
            ),
          ),
        ),
      ],
    );
  }
}
