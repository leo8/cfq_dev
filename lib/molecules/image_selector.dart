import 'dart:typed_data';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/icons.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';

class ImageSelector extends StatelessWidget {
  final Uint8List? image;
  final VoidCallback onSelectImage;
  final String placeholderText;

  const ImageSelector({
    required this.image,
    required this.onSelectImage,
    this.placeholderText = 'No Image Selected',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 300,
          height: 120,
          decoration: BoxDecoration(
            color: CustomColor.secondaryColor[800],
            borderRadius: BorderRadius.circular(10),
            image: image != null
                ? DecorationImage(
                    image: MemoryImage(image!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: image == null
              ? Center(
                  child: Text(
                    placeholderText,
                    style: const TextStyle(
                      color: CustomColor.white70,
                      fontSize: CustomFont.fontSize10,
                    ),
                  ),
                )
              : null,
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onSelectImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: CustomColor.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CustomIcon.addAPhoto,
                color: CustomColor.primaryColor,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
