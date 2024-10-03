import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';

/// A non-editable widget that displays the selected date and time.
/// It triggers a callback when tapped to allow date-time selection.
class DateTimeSelector extends StatelessWidget {
  final String dateTimeText; // Text to display the selected date and time
  final VoidCallback onTap; // Callback to trigger the date-time picker
  final double? height; // Optional height parameter

  const DateTimeSelector({
    required this.dateTimeText,
    required this.onTap,
    this.height, // Optional height
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Triggers the date-time picker
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
              Icons.calendar_today,
              color: CustomColor.white,
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              dateTimeText,
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
