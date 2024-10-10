import 'dart:typed_data';

import 'package:cfq_dev/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
/// This function is typically used to show short notifications or errors in the app.
void showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}
