import 'package:cfq_dev/utils/string.dart';
import 'package:flutter/material.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(CustomString.thisIsWeb)),
    );
  }
}
