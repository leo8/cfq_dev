import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/styles/colors.dart';

class CustomDateField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final DateTime? selectedDate; // Store the selected DateTime object
  final Widget? suffixIcon;
  final Function(DateTime?) onDateChanged; // Callback to return the selected date

  const CustomDateField({
    required this.controller,
    required this.hintText,
    this.selectedDate,
    this.suffixIcon,
    required this.onDateChanged,
    super.key,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900), // Defaults to 1900
      lastDate: DateTime.now(),  // Defaults to the current date
    );
    if (pickedDate != null) {
      // Update the text field with the selected date
      controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      // Call the callback to pass the selected DateTime
      onDateChanged(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context), // Opens the date picker when tapped
      child: AbsorbPointer( // Prevents direct editing of the field
        child: Container(
          decoration: BoxDecoration(
            color: CustomColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: CustomColor.primaryColor),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: CustomColor.white70),
              border: InputBorder.none,
              suffixIcon: suffixIcon ?? const Icon(Icons.calendar_today, color: CustomColor.white70),
            ),
            readOnly: true, // Prevents keyboard input
          ),
        ),
      ),
    );
  }
}
