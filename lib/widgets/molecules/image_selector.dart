import 'dart:typed_data';
import 'package:cfq_dev/utils/styles/string.dart';
import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../../utils/styles/text_styles.dart';
import '../../utils/styles/icons.dart';

class ImageSelector extends StatelessWidget {
  final Uint8List? image; // Holds the selected image data
  final VoidCallback onSelectImage; // Callback when image is selected
  final String
      placeholderText; // Placeholder text displayed when no image is selected

  const ImageSelector({
    required this.image,
    required this.onSelectImage,
    this.placeholderText = CustomString.pleaseSelectAnImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container that holds the image or placeholder text
        Container(
          width: 300, // Fixed width
          height: 120, // Fixed height
          decoration: BoxDecoration(
            color: CustomColor
                .secondaryColor[800], // Background color when no image
            borderRadius: BorderRadius.circular(10), // Rounded corners
            image: image != null
                ? DecorationImage(
                    image: MemoryImage(image!), // Display selected image
                    fit: BoxFit.cover, // Cover the container
                  )
                : null, // No image
          ),
          child: image == null
              ? Center(
                  child: Text(
                    placeholderText, // Placeholder text when no image is selected
                    style: CustomTextStyle.xsBody,
                  ),
                )
              : null, // No placeholder if the image is present
        ),
        // Icon for selecting a new image
        Positioned(
          top: 5, // Position the icon at the top-right corner
          right: 5,
          child: GestureDetector(
            onTap: onSelectImage, // Calls the provided callback when tapped
            child: Container(
              padding:
                  const EdgeInsets.all(4), // Padding inside the icon button
              decoration: const BoxDecoration(
                color:
                    CustomColor.purple, // Background color for the icon button
                shape: BoxShape.circle, // Circular shape for the icon button
              ),
              child: const Icon(
                CustomIcon.addImage, // Photo icon for selecting a new image
                color: CustomColor.white,
                size: 16, // Icon size
              ),
            ),
          ),
        ),
      ],
    );
  }
}
