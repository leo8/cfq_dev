import 'package:flutter/material.dart';
import 'package:cfq_dev/screens/create_cfq_screen.dart';
import 'package:cfq_dev/utils/logger.dart';

class CfqButton extends StatelessWidget {
  const CfqButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppLogger.debug("Navigating to AddCfqScreen");
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CreateCfqScreen()),
        );
      },
      child: Image.asset(
        'assets/cfq_button.png',
        width: 60,
        height: 60,
      ),
    );
  }
}
