import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/texts/custom_text.dart';
import '../../utils/styles/colors.dart';

class DescriptionSection extends StatelessWidget {
  final String description; // The description text to display

  const DescriptionSection({
    required this.description, // Accepts a description to be displayed
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: description, // Displays the passed description
      color:
          CustomColor.white70, // Text color is set to a semi-transparent white
    );
  }
}
