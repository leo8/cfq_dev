import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/ressources/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/auth_template.dart';
import 'package:cfq_dev/organisms/login_form.dart';
import 'package:cfq_dev/molecules/signup_option.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:cfq_dev/utils/colors.dart';
import 'package:cfq_dev/utils/fonts.dart';
import 'package:cfq_dev/utils/string.dart';
import 'package:cfq_dev/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RepsonsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      showSnackBar(res, context);
    }
  }

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
          // Logo
          Image.asset(
            'assets/logo_white.png',
            height: 250,
            color: CustomColor.deepPurpleAccent,
          ),
          const SizedBox(height: 64),
          // Login Form
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
          // Sign-Up Option
          SignUpOption(onTap: navigateToSignUp),
        ],
      ),
    );
  }
}
