import 'package:flutter/material.dart';

class ProgressBarLogin extends StatefulWidget {
  final double pourcentProgression;
  final double height = 15;
  final double fullWidth = double.infinity;
  final double widthProgressFull;

  @override
  // ignore: library_private_types_in_public_api
  _ProgressBarLoginState createState() => _ProgressBarLoginState();

  const ProgressBarLogin(
      {super.key,
      required this.widthProgressFull,
      required this.pourcentProgression});
}

class _ProgressBarLoginState extends State<ProgressBarLogin> {
  double _currentProgress = 0.0;

  @override
  void didUpdateWidget(covariant ProgressBarLogin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pourcentProgression != widget.pourcentProgression) {
      setState(() {
        _currentProgress = widget.pourcentProgression;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.pourcentProgression;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.widthProgressFull,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white),
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: widget.widthProgressFull * _currentProgress,
          height: widget.height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
      ],
    );
  }
}
