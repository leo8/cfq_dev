import 'package:cfq_dev/atoms/texts/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/string.dart';

class UsernameLocationFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController locationController;

  const UsernameLocationFields({
    required this.usernameController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: usernameController,
            hintText: CustomString.unPetitNom,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomTextField(
            controller: locationController,
            hintText: CustomString.taLocalisation,
          ),
        ),
      ],
    );
  }
}
