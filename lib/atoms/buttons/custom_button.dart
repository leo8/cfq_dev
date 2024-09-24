import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const CustomButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: CustomColor.primaryColor,
              ),
            )
          : Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [CustomColor.personnalizedPurple, Color(0xFF7900F4)],
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: CustomColor.primaryColor,
                  fontWeight: CustomFont.fontWeightBold,
                  fontSize: CustomFont.fontSize18,
                ),
              ),
            ),
    );
  }
}
