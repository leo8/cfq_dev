import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/profile_image_avatar.dart';
import 'package:cfq_dev/widgets/molecules/username_location_field.dart';

import '../../utils/styles/string.dart';
import '../atoms/buttons/custom_button.dart';
import '../atoms/texts/custom_text_field.dart';

class SignUpForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final TextEditingController locationController;
  final TextEditingController bioController;
  final Uint8List? image;
  final VoidCallback onImageSelected;
  final VoidCallback onSignUp;
  final bool isLoading;

  const SignUpForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.locationController,
    required this.bioController,
    this.image,
    required this.onImageSelected,
    required this.onSignUp,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileImageAvatar(
          image: image,
          onImageSelected: onImageSelected,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: emailController,
          hintText: CustomString.tonMail,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: passwordController,
          hintText: CustomString.tonMotDePasse,
          obscureText: true,
        ),
        const SizedBox(height: 8),
        UsernameLocationFields(
          usernameController: usernameController,
          locationController: locationController,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: bioController,
          hintText: CustomString.taBio,
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: CustomString.inscriptionCapital,
          onTap: onSignUp,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
