import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';

class AuthTemplate extends StatelessWidget {
  final Widget body;

  const AuthTemplate({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1617957689233-207e3cd3c610?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: body,
        ),
      ),
    );
  }
}
