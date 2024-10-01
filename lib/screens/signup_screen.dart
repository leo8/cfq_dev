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

/// Signup screen to register new users and collect necessary information.
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
  final TextEditingController _birthDateController =
      TextEditingController(); // Birth date input controller
  DateTime? _selectedBirthDate; // Stores the selected birth date
  Uint8List? _image; // Stores the selected profile image
  bool _isLoading = false; // Tracks loading state for signup process

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _birthDateController.dispose();
  }

  /// Opens gallery to select a profile image.
  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im; // Sets the selected image
    });
  }

  /// Attempts to sign up the user with the provided information.
  void signUpUser() async {
    setState(() {
      _isLoading = true; // Show loading state
    });

    // Call AuthMethods to sign up the user
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
      _isLoading = false; // Hide loading state
    });

    if (res != CustomString.success) {
      showSnackBar(res, context); // Show error message if signup fails
    } else {
      // Navigate to the main layout on successful signup
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

  /// Navigate to the login screen when the user chooses to log in instead.
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
            // Display the app logo
            Image.asset(
              'assets/logo_white.png',
              height: 250,
              color: CustomColor.white,
            ),
            const SizedBox(height: 20),
            // Sign-Up Form collects user information
            SignUpForm(
              emailController: _emailController,
              passwordController: _passwordController,
              usernameController: _usernameController,
              locationController: _locationController,
              bioController: _bioController,
              birthDateController:
                  _birthDateController, // Pass the birth date controller
              selectedBirthDate:
                  _selectedBirthDate, // Pass current selected date
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
            // Display a separator for alternative options
            const Text(
              CustomString.ouCapital,
              style: TextStyle(color: CustomColor.white70),
            ),
            const SizedBox(height: 8),
            // Option to navigate to the login screen
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
