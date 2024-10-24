import 'dart:typed_data';

import 'package:cfq_dev/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/string.dart';
import '../utils/styles/colors.dart';

/// Picks an image from the specified [ImageSource] (camera or gallery).
/// If an image is picked, it returns the image as a Uint8List.
/// If no image is selected, it logs a debug message.
Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  // Let user pick an image from the specified source
  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    // Read image bytes and return
    return await file.readAsBytes();
  }

  // Log when no image is selected
  AppLogger.debug('No image selected');
  return null;
}

/// Displays a [SnackBar] with the given [content] in the provided [BuildContext].
/// This function shows the snack bar at the top of the screen.
void showSnackBar(String content, BuildContext context) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 15,
      left: 8,
      right: 8,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).snackBarTheme.backgroundColor ??
            CustomColor.customBlack,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: Text(
              content,
              style: Theme.of(context).snackBarTheme.contentTextStyle ??
                  CustomTextStyle.body1,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

/// Shows a dialog to choose between gallery and camera for image selection
Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
  return showDialog<ImageSource>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text(
                  CustomString.pickImageFromGallery,
                  style: CustomTextStyle.body1,
                ),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              const Padding(padding: EdgeInsets.all(6.0)),
              const Divider(),
              const Padding(padding: EdgeInsets.all(6.0)),
              GestureDetector(
                child: Text(
                  CustomString.takePictureWithDevice,
                  style: CustomTextStyle.body1,
                ),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
