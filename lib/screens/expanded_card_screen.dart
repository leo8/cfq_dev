import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';

class ExpandedCardScreen extends StatelessWidget {
  final Widget cardContent;

  const ExpandedCardScreen({Key? key, required this.cardContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: cardContent,
      ),
    );
  }
}
