import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text_field.dart';
import 'package:cfq_dev/utils/string.dart';

class AddressFieldsRow extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController addressController;

  const AddressFieldsRow({
    required this.locationController,
    required this.addressController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: locationController,
            hintText: CustomString.ou,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomTextField(
            controller: addressController,
            hintText: CustomString.adresse,
          ),
        ),
      ],
    );
  }
}
