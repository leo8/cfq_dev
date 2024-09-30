import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cfq_dev/templates/auth_template.dart';
import 'package:cfq_dev/utils/utils.dart';
import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../widgets/molecules/signup_option.dart';
import '../widgets/organisms/signup_form.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController(); // New birth date controller
  DateTime? _selectedBirthDate; // Store the selected birth date
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _birthDateController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      profilePicture: _image != null ? _image! : null,
      location: _locationController.text,
      birthDate: _selectedBirthDate, // Pass selected birth date
    );
    setState(() {
      _isLoading = false;
    });
    if (res != CustomString.success) {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RepsonsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    }
  }

  void navigateToLogIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo
            Image.asset(
              'assets/logo_white.png',
              height: 250,
              color: CustomColor.primaryColor,
            ),
            const SizedBox(height: 20),
            // Sign-Up Form
            SignUpForm(
              emailController: _emailController,
              passwordController: _passwordController,
              usernameController: _usernameController,
              locationController: _locationController,
              bioController: _bioController,
              birthDateController: _birthDateController, // Pass the birthdate controller
              selectedBirthDate: _selectedBirthDate, // Pass current selected date
              onBirthDateChanged: (DateTime? newDate) {
                setState(() {
                  _selectedBirthDate = newDate; // Update selected birth date
                });
              },
              image: _image,
              onImageSelected: selectImage,
              onSignUp: signUpUser,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 8),
            const Text(
              CustomString.ouCapital,
              style: TextStyle(color: CustomColor.white70),
            ),
            const SizedBox(height: 8),
            // Log In Option
            SignUpOption(
              questionText: CustomString.dejaInscrit,
              actionText: CustomString.jeMeConnecte,
              onTap: navigateToLogIn,
            ),
          ],
        ),
      ),
    );
  }
}
