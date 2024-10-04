import 'package:flutter/material.dart';

class NeonSwitch extends StatelessWidget {
  final double size;
  final bool value; // Current value (ON or OFF)
  final Function(bool)?
      onChanged; // Callback for when the value changes, nullable

  NeonSwitch({
    this.onChanged, // Nullable onChanged
    this.size = 1.0, // Default size is 1.0
    this.value = false, // Default value is OFF
    Key? key,
  }) : super(key: key);

  void toggleSwitch(BuildContext context) {
    if (onChanged != null) {
      onChanged!(!value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate sizes based on the provided size factor with clamping for responsiveness
    double switchWidth = (180 * size).clamp(100.0, 300.0);
    double switchHeight = (50 * size).clamp(30.0, 100.0);
    double toggleSize = (60 * size).clamp(40.0, 80.0);
    double iconSize = (40 * size).clamp(20.0, 60.0);
    double toggleLeftPosition = value
        ? (160 * size).clamp(100.0, 200.0)
        : (10 * size).clamp(5.0, 15.0); // Adjust toggle position

    return InkWell(
      onTap: () => toggleSwitch(context),
      borderRadius: BorderRadius.circular(
          25 * size), // Match the container's border radius
      child: Container(
        width: (220 * size)
            .clamp(150.0, 350.0), // Adjust width proportionally with clamping
        height: (70 * size)
            .clamp(40.0, 120.0), // Adjust height proportionally with clamping
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sliding bar with text
            Container(
              width: switchWidth,
              height: switchHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 22, 1, 57),
                borderRadius: BorderRadius.circular(25 * size), // Adjust radius
                border: Border.all(
                    color: Colors.white,
                    width: 2 * size), // Adjust border width
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    value ? 'TURN' : 'OFF',
                    key: ValueKey(value),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20 * size), // Adjust font size
                  ),
                ),
              ),
            ),
            // Circle toggle with neon effect
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut, // Smoother animation
              left:
                  toggleLeftPosition, // Move toggle to left or right based on size
              child: Container(
                width: toggleSize,
                height: toggleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 22, 1, 57),
                  border: Border.all(
                    color: value
                        ? Colors.cyanAccent
                        : Colors.purpleAccent, // Neon-colored border
                    width:
                        3 * size, // Adjust the width for a thicker neon effect
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: value
                          ? Colors.cyanAccent
                          : Colors.purpleAccent, // Neon glow color
                      blurRadius: 15 * size, // Adjust shadow blur
                      spreadRadius: 3 * size, // Adjust shadow spread
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    value ? Icons.public : Icons.nights_stay_outlined,
                    color: Colors.white,
                    size: iconSize, // Adjust icon size
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
