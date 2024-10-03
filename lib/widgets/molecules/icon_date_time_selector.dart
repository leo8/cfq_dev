import 'package:flutter/material.dart';
import '../atoms/dates/date_time_selector.dart';

/// A molecule that combines an icon with a date-time selector.
/// The icon is integrated inside the container and non-editable.
class IconDateTimeSelector extends StatelessWidget {
  final String dateTimeText; // Text to display the selected date and time
  final VoidCallback onTap; // Callback to trigger the date-time picker
  final double? height; // Optional height parameter

  const IconDateTimeSelector({
    required this.dateTimeText,
    required this.onTap,
    this.height, // Optional height
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DateTimeSelector(
      dateTimeText: dateTimeText,
      onTap: onTap,
      height: height, // Pass the height parameter
    );
  }
}
