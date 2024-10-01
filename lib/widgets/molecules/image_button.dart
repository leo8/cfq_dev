import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/fonts.dart';

class ImageButton extends StatelessWidget {
  final String title; // Title displayed in the center of the button
  final String imageUrl; // URL for the background image
  final VoidCallback onTap; // Callback when the button is tapped

  const ImageButton({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Triggers the provided onTap callback when tapped
      child: Container(
        height: 180, // Fixed height for the button
        padding: const EdgeInsets.all(20), // Internal padding for content
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          image: DecorationImage(
            image: NetworkImage(imageUrl), // Background image
            fit: BoxFit.cover, // Ensures the image covers the container
            colorFilter: const ColorFilter.mode(
              CustomColor.deepPurpleAccent, // Adds a purple overlay
              BlendMode.overlay, // Overlay blend mode
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: CustomColor.personnalizedPurple, // Shadow color
              spreadRadius: 5, // How far the shadow spreads
              blurRadius: 10, // Blurriness of the shadow
              offset: Offset(0, 5), // Position of the shadow
            ),
          ],
        ),
        child: Center(
          // Centers the title text within the button
          child: CustomText(
            text: title, // Displays the button title
            fontSize: CustomFont.fontSize30, // Large text size
            fontWeight: CustomFont.fontWeightBold, // Bold font weight
            color: CustomColor.white, // White text color
          ),
        ),
      ),
    );
  }
}
