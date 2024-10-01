import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';

class DescriptionSection extends StatelessWidget {
  final String description;

  const DescriptionSection({
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: description,
      color: CustomColor.white70,
    );
  }
}
