import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/styles/colors.dart';

class CustomDateField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final DateTime? selectedDate; // Holds the currently selected date
  final Widget? suffixIcon;
  final Function(DateTime?) onDateChanged; // Callback to handle date selection

  const CustomDateField({
    required this.controller,
    required this.hintText,
    this.selectedDate,
    this.suffixIcon,
    required this.onDateChanged,
    super.key,
  });

  // Opens the date picker dialog and updates the controller with the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ??
          DateTime.now(), // Defaults to current date if none selected
      firstDate: DateTime(1900), // Sets the earliest selectable date
      lastDate: DateTime.now(), // Sets the latest selectable date
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}"; // Formats and sets the selected date in the controller
      onDateChanged(
          pickedDate); // Passes the selected date back via the callback
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context), // Taps open the date picker
      child: AbsorbPointer(
        // Prevents direct text input
        child: Container(
          decoration: BoxDecoration(
            color: CustomColor.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller:
                controller, // Controller that holds the selected date text
            style: const TextStyle(color: CustomColor.white70),
            decoration: InputDecoration(
              hintText: hintText, // Placeholder text when no date is selected
              hintStyle: const TextStyle(color: CustomColor.white70),
              border: InputBorder.none,
              suffixIcon: suffixIcon ??
                  const Icon(Icons.calendar_today,
                      color: CustomColor.white70), // Icon for date selection
            ),
            readOnly: true, // Disables manual input, making it read-only
          ),
        ),
      ),
    );
  }
}
