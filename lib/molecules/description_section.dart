import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text.dart';
import 'package:cfq_dev/utils/colors.dart';

class DescriptionSection extends StatelessWidget {
  final String description;

  const DescriptionSection({
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: description,
      color: CustomColor.white70,
    );
  }
}
