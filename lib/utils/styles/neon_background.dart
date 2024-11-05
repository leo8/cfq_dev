import 'package:flutter/material.dart';

class NeonBackground extends StatelessWidget {
  final Widget child;

  const NeonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/neon_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
