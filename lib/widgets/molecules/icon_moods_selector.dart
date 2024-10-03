import 'package:flutter/material.dart';
import '../atoms/moods/moods_selector.dart';

/// A molecule that combines an icon with a moods selector.
/// The icon is integrated inside the container and non-editable.
class IconMoodsSelector extends StatelessWidget {
  final String moodsText; // Text to display the selected moods
  final VoidCallback onTap; // Callback to trigger the moods selection dialog
  final double? height; // Optional height parameter

  const IconMoodsSelector({
    required this.moodsText,
    required this.onTap,
    this.height, // Optional height
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MoodsSelector(
      moodsText: moodsText,
      onTap: onTap,
      height: height, // Pass the height parameter
    );
  }
}
