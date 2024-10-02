import 'package:flutter/material.dart';
import 'package:cfq_dev/screens/add_turn_screen.dart';
import 'package:cfq_dev/utils/logger.dart';

class TurnButton extends StatelessWidget {
  const TurnButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppLogger.debug("Navigating to AddTurnScreen");
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddTurnScreen()),
        );
      },
      child: Image.asset(
        'assets/turn_button.png',
        width: 60,
        height: 60,
      ),
    );
  }
}
