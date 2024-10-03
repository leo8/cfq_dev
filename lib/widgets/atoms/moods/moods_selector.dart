import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';

/// A non-editable widget that displays the selected moods.
/// It triggers a callback when tapped to allow mood selection.
class MoodsSelector extends StatelessWidget {
  final String moodsText; // Text to display the selected moods
  final VoidCallback onTap; // Callback to trigger the moods selection dialog
  final double? height; // Optional height parameter

  const MoodsSelector({
    required this.moodsText,
    required this.onTap,
    this.height, // Optional height
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Triggers the moods selection dialog
      child: Container(
        height: height ?? 50.0, // Default height if not provided
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: CustomColor.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.tag_faces,
              color: CustomColor.white,
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              moodsText,
              style: const TextStyle(
                color: CustomColor.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
