import 'package:flutter/material.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/colors.dart';

class NeonSwitch extends StatelessWidget {
  final double size;
  final bool value;
  final Function(bool)? onChanged;

  const NeonSwitch({
    super.key,
    this.onChanged,
    this.size = 0.3,
    this.value = false,
  });

  void toggleSwitch() {
    if (onChanged != null) {
      onChanged!(!value);
    }
  }

  @override
  Widget build(BuildContext context) {
    double switchWidth = 60 * size;
    double switchHeight = 30 * size;
    double toggleSize = 26 * size;
    double iconSize = 16 * size;
    double toggleLeftPosition = value ? switchWidth - toggleSize - 2 : 2;

    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: switchWidth,
        height: switchHeight,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 22, 1, 57),
          borderRadius: BorderRadius.circular(15 * size),
          border: Border.all(color: CustomColor.white, width: 1 * size),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: toggleLeftPosition,
              top: 2,
              child: Container(
                width: toggleSize,
                height: toggleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 22, 1, 57),
                  border: Border.all(
                    color: value ? CustomColor.turnColor : CustomColor.offColor,
                    width: 1 * size,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          value ? CustomColor.turnColor : CustomColor.offColor,
                      blurRadius: 5 * size,
                      spreadRadius: 1 * size,
                    ),
                  ],
                ),
                child: Center(
                  child: value
                      ? CustomIcon.statusOn.copyWith(size: iconSize)
                      : CustomIcon.statusOff.copyWith(size: iconSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
