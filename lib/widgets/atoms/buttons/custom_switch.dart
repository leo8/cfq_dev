import 'package:flutter/material.dart';
import '../../../utils/styles/colors.dart';

class CustomSwitch extends StatelessWidget {
  final bool value; // Current value of the switch (true or false)
  final ValueChanged<bool> onChanged; // Callback to handle value change

  const CustomSwitch({
    required this.value, // The current state of the switch (required)
    required this.onChanged, // Callback function triggered when the switch is toggled (required)
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value, // The state of the switch (on/off)
      onChanged: onChanged, // Function to handle state changes
      activeColor: CustomColor.greenColor, // Color of the switch when active
      inactiveThumbColor:
          CustomColor.secondaryColor, // Color of the switch thumb when inactive
      inactiveTrackColor:
          CustomColor.white70, // Color of the switch track when inactive
    );
  }
}
