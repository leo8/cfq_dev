import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/styles/neon_background.dart';
import '../../utils/styles/colors.dart';

class AuthTemplate extends StatelessWidget {
  final Widget body;

  const AuthTemplate({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: CustomColor.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: body,
          ),
        ),
      ),
    );
  }
}
