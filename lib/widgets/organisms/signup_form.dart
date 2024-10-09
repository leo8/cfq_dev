import 'dart:typed_data'; // Import for handling image data
import 'package:cfq_dev/widgets/atoms/dates/custom_date_field.dart'; // Import custom date field widget
import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/atoms/avatars/profile_image_avatar.dart'; // Import profile image avatar widget
import 'package:cfq_dev/widgets/molecules/username_location_field.dart'; // Import custom username and location fields

import '../../utils/styles/string.dart'; // Import string constants
import '../atoms/buttons/custom_button.dart'; // Import custom button widget
import '../atoms/texts/custom_text_field.dart'; // Import custom text field widget

class SignUpForm extends StatelessWidget {
  final TextEditingController emailController; // Controller for email input
  final TextEditingController
      passwordController; // Controller for password input
  final TextEditingController
      usernameController; // Controller for username input
  final TextEditingController
      locationController; // Controller for location input
  final Uint8List? image; // Selected image for profile
  final TextEditingController
      birthDateController; // Controller for birth date input
  final DateTime? selectedBirthDate; // Currently selected birth date
  final bool isLoading; // Flag for loading state
  final VoidCallback onImageSelected; // Function to handle image selection
  final VoidCallback onSignUp; // Function to handle sign-up action
  final Function(DateTime?)
      onBirthDateChanged; // Callback for changes in birth date

  const SignUpForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.locationController,
    this.image,
    required this.birthDateController,
    this.selectedBirthDate, // Pass the currently selected date
    this.isLoading = false, // Default loading state to false
    required this.onImageSelected,
    required this.onSignUp,
    required this.onBirthDateChanged, // Required callback for date change
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile image section with selection functionality
        ProfileImageAvatar(
          image: image,
          onImageSelected: onImageSelected,
        ),
        const SizedBox(height: 12),
        // Email input field
        CustomTextField(
          controller: emailController,
          hintText: CustomString.tonMail, // "Your Email"
        ),
        const SizedBox(height: 8),
        // Password input field
        CustomTextField(
          controller: passwordController,
          hintText: CustomString.tonMotDePasse, // "Your Password"
          obscureText: true, // Hides password input
        ),
        const SizedBox(height: 8),
        // Username and location input fields
        UsernameLocationFields(
          usernameController: usernameController,
          locationController: locationController,
        ),
        const SizedBox(height: 8),
        // Birth date input field
        CustomDateField(
          controller: birthDateController,
          hintText: CustomString.taDateDeNaissance, // "Your Birth Date"
          selectedDate: selectedBirthDate, // Pass the currently selected date
          onDateChanged:
              onBirthDateChanged, // Trigger callback on date selection
        ),
        const SizedBox(height: 12),
        // Submit button for signing up
        CustomButton(
          label: CustomString.inscriptionCapital, // "Sign Up"
          onTap: onSignUp, // Trigger sign-up action
          isLoading: isLoading, // Show loading indicator if true
        ),
      ],
    );
  }
}
