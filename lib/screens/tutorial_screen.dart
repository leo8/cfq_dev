import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 1;

  void _handleTap() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Scaffold(
        backgroundColor: CustomColor.customBlack,
        body: Image.asset(
          'assets/images/onBoardingStep$_currentStep.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
