import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/ui/molecules/forgot_password_link.dart';

import '../../gen/colors.dart';
import '../../gen/icons.dart';
import '../../gen/string.dart';
import '../atoms/buttons/custom_button.dart';
import '../atoms/texts/custom_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final bool isLoading;

  const LoginForm({super.key, 
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
