import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:cfq_dev/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/auth_template.dart';
import 'package:cfq_dev/utils/utils.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../widgets/molecules/signup_option.dart';
import '../widgets/organisms/login_form.dart';

/// Login screen where users can log in or navigate to the sign-up screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(); // Controller for the email field
  final TextEditingController _passwordController =
      TextEditingController(); // Controller for the password field
  bool _isLoading = false; // Tracks if the login process is in progress

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Function to handle the login process.
  void logInUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().logInUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (res == CustomString.success) {
      // Navigate to the appropriate layout after successful login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const RepsonsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
        (route) => false,  
      );
    } else {
      // Show error message if login fails
      showSnackBar(res, context);
    }
  }

  /// Navigate to the sign-up screen.
  void navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // App logo
          Image.asset(
            'assets/logo_white.png',
            height: 250,
            color: CustomColor.deepPurpleAccent,
          ),
          const SizedBox(height: 64),
          // Login form that includes email and password fields
          LoginForm(
            emailController: _emailController,
            passwordController: _passwordController,
            onLogin: logInUser,
            onForgotPassword: () {}, // Implement forgot password functionality
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          const Text(
            CustomString.ouCapital,
            style: TextStyle(color: CustomColor.white70),
          ),
          const SizedBox(height: 16),
          // Sign-up option below the form
          SignUpOption(
            questionText: CustomString.tAsPasEncoreDeCompte,
            actionText: CustomString.jemInscris,
            onTap: navigateToSignUp,
          ),
        ],
      ),
    );
  }
}
