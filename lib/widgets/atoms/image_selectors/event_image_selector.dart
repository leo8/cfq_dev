import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/colors.dart';

class EventImageSelector extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onSelectImage;
  final double width;
  final double height;

  const EventImageSelector({
    super.key,
    required this.image,
    required this.onSelectImage,
    this.width = 283,
    this.height = 127,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelectImage,
      child: Stack(
        children: [
          // Grey Rectangle Container
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: CustomColor.customDarkGrey, // Grey background
              //borderRadius: BorderRadius.circular(8.0), // Rounded corners
              image: image != null
                  ? DecorationImage(
                      image: MemoryImage(image!),
                      fit: BoxFit.cover, // Cover the entire container
                    )
                  : null,
            ),
          ),
          // White Photo Upload Icon Positioned at Bottom Right
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: CustomIcon.addImage
                  .copyWith(color: CustomColor.customWhite, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
