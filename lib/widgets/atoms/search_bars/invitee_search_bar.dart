import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:flutter/material.dart';

class InviteeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String hintText;

  const InviteeSearchBar({
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search friends to invite',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) => onSearch(),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: CustomColor.white),
        hintText: hintText,
        filled: true,
        fillColor: CustomColor.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
