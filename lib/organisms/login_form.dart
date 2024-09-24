import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/icons.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/atoms/texts/custom_text_field.dart';
import 'package:cfq_dev/atoms/buttons/custom_button.dart';
import 'package:cfq_dev/molecules/forgot_password_link.dart';
import 'package:cfq_dev/utils/string.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final bool isLoading;

  const LoginForm({
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
          hintText: CustomString.tonMail,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: passwordController,
          hintText: CustomString.tonMotDePasse,
          obscureText: true,
          suffixIcon: const Icon(CustomIcon.visibility, color: CustomColor.white70),
        ),
        const SizedBox(height: 4),
        ForgotPasswordLink(onTap: onForgotPassword),
        const SizedBox(height: 64),
        CustomButton(
          label: CustomString.connexionCapital,
          onTap: onLogin,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
