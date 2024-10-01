import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/fonts.dart';

class CustomGradientButton extends StatelessWidget {
  final String text; // The label/text displayed on the button
  final VoidCallback onTap; // The function triggered when the button is pressed

  const CustomGradientButton({
    required this.text, // The text is required to be passed to the button
    required this.onTap, // The onTap callback function is required
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Triggers the provided onTap callback when pressed
      child: Container(
        width: double.infinity, // Button takes the full width of its parent
        alignment: Alignment.center, // Centers the text inside the button
        padding:
            const EdgeInsets.symmetric(vertical: 16), // Adds vertical padding
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(30), // Rounded corners with a radius of 30
          gradient: const LinearGradient(
            colors: [
              CustomColor.personnalizedPurple,
              Color(0xFF7900F4)
            ], // Gradient color for the button
          ),
        ),
        child: CustomText(
          // Custom text widget to display the button's label
          text: text,
          fontSize: CustomFont.fontSize18, // Font size of the text
          fontWeight: CustomFont.fontWeightBold, // Bold font weight
          color: CustomColor.white, // White text color
        ),
      ),
    );
  }
}
