import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utils/styles/icons.dart';

class EventImageSelector extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onSelectImage;
  final double width;
  final double height;

  const EventImageSelector({
    super.key,
    required this.image,
    required this.onSelectImage,
    this.width = double.infinity,
    this.height = 200.0,
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
              color: Colors.grey[300], // Grey background
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              image: image != null
                  ? DecorationImage(
                      image: MemoryImage(image!),
                      fit: BoxFit.cover, // Cover the entire container
                    )
                  : null,
            ),
            child: image == null
                ? const Center(
                    child: Icon(
                      CustomIcon.addImage,
                      color: Colors.white,
                      size: 50,
                    ),
                  )
                : null,
          ),
          // White Photo Upload Icon Positioned at Bottom Right
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // White background for the icon button
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Icon(
                CustomIcon.addImage,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
