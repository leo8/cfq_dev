import 'package:flutter/material.dart';
import 'package:cfq_dev/widgets/molecules/forgot_password_link.dart';

import '../../utils/styles/colors.dart';
import '../../utils/styles/icons.dart';
import '../../utils/styles/string.dart';
import '../atoms/buttons/custom_button.dart';
import '../atoms/texts/custom_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController; // Controller for the email input
  final TextEditingController
      passwordController; // Controller for the password input
  final VoidCallback onLogin; // Function to execute login action
  final VoidCallback
      onForgotPassword; // Function to execute forgot password action
  final bool isLoading; // Indicates loading state for the login button

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onForgotPassword,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: emailController,
          hintText: CustomString.yourEmail, // Placeholder for email input
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: passwordController,
          hintText: CustomString.yourPassword, // Placeholder for password input
          obscureText: true, // Hides the password for security
          suffixIcon: const Icon(CustomIcon.visibility,
              color:
                  CustomColor.white70), // Icon for password visibility toggle
        ),
        const SizedBox(height: 4),
        ForgotPasswordLink(
            onTap: onForgotPassword), // Link to initiate password recovery
        const SizedBox(height: 64),
        CustomButton(
          label: CustomString.logInCapital, // Label for the login button
          onTap: onLogin, // Function to call on button press
          isLoading: isLoading, // Show loading indicator if true
        ),
      ],
    );
  }
}
