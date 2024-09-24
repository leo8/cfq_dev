import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';

class StandardFormTemplate extends StatelessWidget {
  final Widget appBarTitle;
  final List<Widget> appBarActions;
  final Widget body;
  final VoidCallback onBackPressed;

  const StandardFormTemplate({
    required this.appBarTitle,
    required this.appBarActions,
    required this.body,
    required this.onBackPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: CustomColor.mobileBackgroundColor,
        centerTitle: true,
        title: appBarTitle,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onBackPressed,
        ),
        actions: appBarActions,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: body,
      ),
    );
  }
}
