import 'package:flutter/material.dart';

class ProfileTemplate extends StatelessWidget {
  final Widget body;
  final String backgroundImageUrl;

  const ProfileTemplate({
    required this.body,
    required this.backgroundImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: body,
      ),
    );
  }
}
