import 'package:flutter/material.dart';

import '../utils/gen/string.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text(CustomString.thisIsWeb)),
    );
  }
}
