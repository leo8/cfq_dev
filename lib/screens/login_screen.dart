import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/ressources/auth_methods.dart';
import 'package:cfq_dev/screens/signup_screen.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:cfq_dev/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';

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
    if (res == 'success') {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1617957689233-207e3cd3c610?q=80&w=2832&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ),
              fit: BoxFit.cover, // Ensures the image covers the entire background
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Spacing from top
              // CaFoutQuoi Logo
              Image.asset(
                'assets/logo_white.png', // Ensure the logo path is correct
                height: 250, // Adjust size as necessary
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20), // Spacing after the logo
              // Title
              const Text(
                'Connexion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Email input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // Semi-transparent background
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white), // Ensures the text is white
                  decoration: InputDecoration(
                    hintText: 'Ton mail',
                    hintStyle: const TextStyle(
                      color: Colors.white70, // Light hint text to ensure visibility
                    ),
                    border: InputBorder.none, // Removing the default border
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Password input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // Semi-transparent background
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ton mot de passe',
                    hintStyle: const TextStyle(
                      color: Colors.white70, // Light hint text to ensure visibility
                    ),
                    border: InputBorder.none, // Removing the default border
                    suffixIcon: const Icon(Icons.visibility, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Forgot password text
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // Add the "Forgot password" functionality here
                  child: const Text(
                    "T’as oublié ton mot de passe ?",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Log in button
              InkWell(
                onTap: logInUser,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7A00FF), Color(0xFF7900F4)],
                          ),
                        ),
                        child: const Text(
                          'CONNECTE-TOI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              const Text(
                'OU',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              // Sign-up option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'T’as pas encore de compte?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: navigateToSignUp,
                    child: const Text(
                      ' INSCRIS-TOI',
                      style: TextStyle(
                        color: Color(0xFF7A00FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
