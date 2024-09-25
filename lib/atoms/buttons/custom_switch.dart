import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: CustomColor.greenColor,
      inactiveThumbColor: CustomColor.secondaryColor,
      inactiveTrackColor: CustomColor.white70,
    );
  }
}
