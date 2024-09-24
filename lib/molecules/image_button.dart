import 'package:cfq_dev/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/utils/colors.dart';

class ImageButton extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const ImageButton({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              CustomColor.deepPurpleAccent,
              BlendMode.overlay,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: CustomColor.personnalizedPurple,
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: CustomText(
            text: title,
            fontSize: CustomFont.fontSize30,
            fontWeight: CustomFont.fontWeightBold,
            color: CustomColor.primaryColor,
          ),
        ),
      ),
    );
  }
}
